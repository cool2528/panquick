#include "httprequest.h"
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QNetworkCookieJar>
#include <QNetworkCookie>

#include <QByteArray>
#include <QEventLoop>
#include <QTimer>
HttpRequest::HttpRequest(QObject *parent) : QObject(parent)
  ,mReply(nullptr)
  ,mCookieJar(nullptr)
  ,mManger(nullptr)
  ,mUrl("")
  ,mIsRedirects(false)
  ,mTimeOut(60000)
{
    mManger = new QNetworkAccessManager(this);
    mCookieJar = new QNetworkCookieJar(this);
    mManger->setCookieJar(mCookieJar);
    mConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
    mConfig.setProtocol(QSsl::TlsV1SslV3);
}

HttpRequest::~HttpRequest()
{
    if(mReply){
        mReply->deleteLater();
        mReply = nullptr;
    }

}

void HttpRequest::setRequestHeader(const QString &key, const QString &value)
{
    if(key.isEmpty()){
        return;
    }
    mHeaders[key] = value;
}

void HttpRequest::setRequestHeader(const QMap<QString,QString> &headers)
{
    if(headers.isEmpty()){
        return;
    }
    auto it = headers.begin();
    for(;it!= headers.end();++it){
        mHeaders[it.key()] = it.value();
    }
}

QString HttpRequest::getCookie()
{
    return getCookie(QUrl(mUrl));
}

QString HttpRequest::getCookie(const QUrl &url)
{
    QString strResult;
    if(!url.isValid()){
        return strResult;
    }
    if(!mCookieJar){
        return strResult;
    }
    for(auto& v : mCookieJar->cookiesForUrl(url)){
        strResult+= v.name() + "=" + v.value() + ";";
    }
    return strResult;
}

bool HttpRequest::hasRawHeader(const QByteArray &headerName)
{
    bool bResult = false;
    if(mReply){
        bResult = mReply->hasRawHeader(headerName);
    }
    return bResult;
}


QString HttpRequest::rawHeader(const QByteArray &headerName)
{
    QString strResult;
    if(mReply){
       strResult = mReply->rawHeader(headerName);
    }
    return strResult;
}

void HttpRequest::send(RequestType type, const QString &url, const QByteArray &data)
{
    if(url.isEmpty()){
        return;
    }
    QUrl urls(url);
    if(urls.isValid()){
        mUrl = url;
    }
    if(mReply){
        mReply->deleteLater();
        mReply = nullptr;
    }
    if(!mData.isEmpty()){
        mData.clear();
    }
    if(mCookieJar){
        mCookieJar->deleteLater();
        mCookieJar = nullptr;
        mCookieJar = new QNetworkCookieJar(this);
        mManger->setCookieJar(mCookieJar);
    }
    QNetworkRequest Requst(urls);
    // 支持HTTPS协议
    Requst.setSslConfiguration(mConfig);
    //协议头设置
    auto it = mHeaders.begin();
    for(;it != mHeaders.end();++it){
        Requst.setRawHeader(it.key().toLatin1(),it.value().toLatin1());
    }
    //重定向设置
    Requst.setAttribute(QNetworkRequest::FollowRedirectsAttribute,QVariant(mIsRedirects));
    QEventLoop loop;
    switch (type) {
    case GET:
       mReply = mManger->get(Requst);
       connect(mReply,&QNetworkReply::finished,&loop,&QEventLoop::quit);
       QTimer::singleShot(mTimeOut,&loop,&QEventLoop::quit);
	   loop.exec();
       if(QNetworkReply::NoError == mReply->error()){
            mData =  mReply->readAll();
       }
    break;
    case POST:
       mReply = mManger->post(Requst,data);
       connect(mReply,&QNetworkReply::finished,&loop,&QEventLoop::quit);
       QTimer::singleShot(mTimeOut,&loop,&QEventLoop::quit);
	   loop.exec();
       if(QNetworkReply::NoError == mReply->error()){
           mData =  mReply->readAll();
       }
    break;
    case HEAD:
         mReply = mManger->head(Requst);
         connect(mReply,&QNetworkReply::finished,&loop,&QEventLoop::quit);
         QTimer::singleShot(mTimeOut,&loop,&QEventLoop::quit);
		 loop.exec();
         if(QNetworkReply::NoError == mReply->error()){
             mData =  mReply->readAll();
         }
    break;
    default:
        break;
    }
    //清空原来的协议头
    mHeaders.clear();
    mManger->clearAccessCache();
}

QByteArray HttpRequest::getBodyContent()
{
    return mData;

}

int HttpRequest::getStatusCode()
{
    int nStatus = 0;
    if(mReply){
        nStatus = mReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
    return nStatus;
}

void HttpRequest::setRedirects(bool status)
{
    mIsRedirects = status;
}

void HttpRequest::setTimeOut(int nSec)
{
    mTimeOut = nSec;
}

QString HttpRequest::getHeaders()
{
    QString strResult;
    if(mReply){
        auto HeaderList = mReply->rawHeaderList();
        for(auto it = HeaderList.begin();it!=HeaderList.end();++it){
            strResult.append(it->data());
            strResult.append(":");
            strResult+= mReply->rawHeader(it->data());
            strResult+="\r\n";
        }
    }
    return strResult;
}
QString HttpRequest::mergeCookie(const QString &newCookie, const QString &oldCookie)
{
   QString result;
   auto newCookieList = newCookie.split(";");
   auto oldCookieList = oldCookie.split(";");
   QHash<QString,QString> mergeHash;
   for(auto v: newCookieList){
       if(!v.isEmpty()){
           auto CookieList  = QNetworkCookie::parseCookies(v.toLocal8Bit());
           for(auto it = CookieList.begin();it!=CookieList.end();++it){
               mergeHash[it->name()] = it->value();
           }
       }
   }
   for(auto v: oldCookieList){
       if(!v.isEmpty()){
           auto CookieList  = QNetworkCookie::parseCookies(v.toLocal8Bit());
           for(auto it = CookieList.begin();it!=CookieList.end();++it){
               mergeHash[it->name()] = it->value();
           }
       }
   }
   for(auto it = mergeHash.begin();it!= mergeHash.end();it++){
       result+= " " + it.key() + "=" + it.value() + ";";
   }
   return result;
}

