#include "cookiemangre.h"
#include <QQuickWebEngineProfile>
#include <QWebEngineCookieStore>
#include <QNetworkCookie>
#include <QNetworkCookieJar>
#include <QStringList>
#include <QDebug>
CookieMangre::CookieMangre(QObject *parent) : QObject(parent)
  ,cookieStore(nullptr)
{
    mCookieJar = new QNetworkCookieJar(this);
}

QString CookieMangre::getcookie(QString url)
{
    for(auto v : mCookieJar->cookiesForUrl(QUrl(url))){
       mCookies+= " " + v.name() + "=" + v.value() + ";";
    }
    return mCookies;
}

void CookieMangre::monitor()
{
    QQuickWebEngineProfile* defaultProfile = QQuickWebEngineProfile::defaultProfile();
    cookieStore = defaultProfile->cookieStore();
    qDebug() << "cookieStore---------" << endl;
    if(!cookieStore)
        return;
    connect(cookieStore,&QWebEngineCookieStore::cookieAdded,this,[this](const QNetworkCookie &cookie){
        mCookieJar->insertCookie(cookie);
    });
    connect(cookieStore,&QWebEngineCookieStore::cookieRemoved,this,[this](const QNetworkCookie &cookie){
        mCookieJar->deleteCookie(cookie);
    });
}

void CookieMangre::cleanCookie()
{
    if(!cookieStore){
        return;
    }
   cookieStore->deleteAllCookies();
   cookieStore->deleteSessionCookies();
   mCookies.clear();

}

QList<QNetworkCookie> CookieMangre::parseCookies(const QString &cookies)
{
    QList<QNetworkCookie> result;
    QStringList cookielist = cookies.split(";");
    for(auto v : cookielist){
        QStringList it = v.split("=");
        QString name = it.value(0);
        QString value;
		if (it.size() > 2) {
			for (size_t i = 1; i < it.size(); ++i) {
				value += it.value(i) + "=";
			}
			value[value.length()-1] = '\0';
		}
		else
		{
			value = it.value(1);
		}
        result.push_back(QNetworkCookie(name.toLocal8Bit(),value.toLocal8Bit()));
    }
    return result;
}
