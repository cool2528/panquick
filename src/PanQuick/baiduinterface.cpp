#include "baiduinterface.h"
#include "nlohmann/json.hpp"
#include <QRegExp>
#include <QFile>
#include <QDateTime>
#include <QFileInfo>
#include <QTextCodec>
#include <QUrl>
#include <QVector>
#include <QStringList>
#include <QNetworkCookie>
using json = nlohmann::json;
BaiduInterface::BaiduInterface()
{
}

QString BaiduInterface::getUserInfo(const QString& cookie)
{
    QString result = "{}";  //失败返回空json对象
    if(cookie.isEmpty()){
        return result;
    }
    //HttpRequest BaiduHttp;
    setRequestHeader("User-Agent",USER_AGENT);
    setRequestHeader("Cookie",cookie);
    send(GET,HOME_URL);
    auto Content = getBodyContent();
#if 0
    QFile file(R"(D:\PDF\1.txt)");
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(Content);
    file.close();
#endif
    QRegExp userRegex("var\\scontext=(.*);\\s");
    userRegex.setMinimal(true);
    if (!userRegex.isValid())
    {
        return result;
    }
    int pos = userRegex.indexIn(Content);
    if(pos > -1){
        QString qsUserinfo = userRegex.cap(1);
        json dc = json::parse(qsUserinfo.toStdString().c_str());
        if(!dc.is_structured()){
            return result;
        }
        json res;
        if(dc.find("username")!= dc.end() && dc["username"].is_string()){
            res["username"] = dc["username"].get<std::string>();
        }
        if(dc.find("bdstoken")!= dc.end() && dc["bdstoken"].is_string()){
            res["bdstoken"] = dc["bdstoken"].get<std::string>();
        }
        if(dc.find("photo")!= dc.end() && dc["photo"].is_string()){
            res["photo"] = dc["photo"].get<std::string>();
        }
        if(dc.find("XDUSS")!= dc.end() && dc["XDUSS"].is_string()){
            res["XDUSS"] = dc["XDUSS"].get<std::string>();
        }
        res["cookies"] = cookie.toStdString();
        result = QString::fromStdString(res.dump());
    }
    return result;
}

QString BaiduInterface::getFileList(const QString &jsondata,const QString& path)
{
    QString result = "{}";  //失败返回空json对象
    if(jsondata.isEmpty()){
        return result;
    }
    json docment = json::parse(jsondata.toStdString().c_str());
    if(docment.is_structured()){
        QString cookie,bdstoken,qsUrl;
        if(docment.find("cookie") != docment.end() && docment["cookie"].is_string()){
            cookie = QString::fromStdString(docment["cookie"].get<std::string>());
        }
        if(docment.find("bdstoken") != docment.end() && docment["bdstoken"].is_string()){
            bdstoken = QString::fromStdString(docment["bdstoken"].get<std::string>());
        }
        qsUrl = QString(PATH_LIST_URL).arg(bdstoken).arg(path);
        // HttpRequest BaiduHttp;
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Referer",HOME_URL);
        send(GET,qsUrl);
        auto qsJson = getBodyContent();
        if(qsJson.isEmpty()){
            return result;
        }
        json listJson = json::parse(qsJson.data());
        if(!listJson.is_structured()){
            return result;
        }
        //判断解析的json 中有没有list
        if(listJson.find("list") != listJson.end() && listJson["list"].is_array()){
            json resultArr;
            for(auto & v:listJson["list"]){
                if(v.is_object()){
                    json fileItem;
                    if(v.find("isdir")!= v.end() && v["isdir"].is_number_unsigned()){
                        fileItem["isdir"] = v["isdir"].get<unsigned int>();
                    }
                    if(v.find("md5")!= v.end() && v["md5"].is_string()){
                        fileItem["md5"] = v["md5"].get<std::string>();
                    }
                    if(v.find("server_filename")!= v.end() && v["server_filename"].is_string()){
                        fileItem["name"] = v["server_filename"].get<std::string>();
                    }
                    if(v.find("path")!= v.end() && v["path"].is_string()){
                        fileItem["path"] = v["path"].get<std::string>();
                    }
                    if(v.find("size")!= v.end() && v["size"].is_number_unsigned()){
                        uint64_t size = v["size"].get<uint64_t>();
                        fileItem["size"] = size > 0 ? formatFileSize(size).toStdString() : "-";
                    }
                    fileItem["check"] = false;
                    if(v.find("fs_id")!= v.end() && v["fs_id"].is_number_unsigned()){
                        fileItem["fs_id"] = v["fs_id"].get<uint64_t>();
                    }
                    if(v.find("server_ctime")!= v.end() && v["server_ctime"].is_number_unsigned()){
                        uint64_t timer = v["server_ctime"].get<uint64_t>();
                        QString fileTime = QDateTime::fromTime_t(qint64(timer)).toString("yyyy-MM-dd HH:mm:ss");
                        fileItem["timer"] = fileTime.toStdString();
                    }
                    uint isdir = fileItem["isdir"].get<uint>();
                    if(isdir){
                        fileItem["type"] = "folder";
                    }else{
                        std::string filePath = fileItem["path"].get<std::string>();
                        QFileInfo info(filePath.c_str());
                        QString suffix = info.suffix();
                        QString path = QString(":/images/%1.png").arg(suffix);
                        if(checkFileExist(path)){
                            fileItem["type"] = suffix.toStdString();
                        }else{
                            fileItem["type"] = "old";
                        }
                    }
                    if(v["thumbs"].is_structured()){
                        fileItem["thumbs"] = 6;
                    }
                    resultArr.push_back(fileItem);
                }
            }
            docment["list"] = resultArr;
        }
        result = QString::fromStdString(docment.dump());
    }
    return result;
}
QString BaiduInterface::urlCoding(const QString& data){
    QString result;
    QByteArray tmpData = data.toUtf8();
    result = tmpData.toPercentEncoding(" ").data();
    return result;
}

QString BaiduInterface::getCookieValue(const QString& cookie,const QString &key)
{
    QString value;
    if(cookie.isEmpty() || key.isEmpty()){
        return value;
    }
    auto oldCookies = cookie.split(";");
    for(auto v : oldCookies){
        if(!v.isEmpty()){
            auto cookieList = QNetworkCookie::parseCookies(v.toLocal8Bit());
            for(auto it = cookieList.begin();it!=cookieList.end();++it){
                if(it->name() == key){
                    value = it->value();
                }
            }
        }
    }
    return value;
}

QString BaiduInterface::random(int len)
{
    QString result;
    int min = 48;int max =122;
    srand(QDateTime::currentMSecsSinceEpoch());
    for(int i = 0;i< len;++i){
        int nResult = rand() % (max - min + 1) + min;
        if(nResult >=97 && nResult <= 122){
            result += QString("%1").arg((char)nResult);
        }else if (nResult >=48 && nResult <= 57){
            result += QString("%1").arg((char)nResult);
        }else{
            result += QString("%1").arg(nResult);
        }
    }
    return result.left(len);
}
bool BaiduInterface::reNameFile(const QString &jsondata, const QString &name, const QString &newName)
{
    bool result = false;
    if(jsondata.isEmpty() || name.isEmpty() || newName.isEmpty()){
        return result;
    }
    json docment = json::parse(jsondata.toStdString().c_str());
    if(docment.is_structured()){
        QString cookie,bdstoken,qsUrl;
        if(docment.find("cookie") != docment.end() && docment["cookie"].is_string()){
            cookie = QString::fromStdString(docment["cookie"].get<std::string>());
        }
        if(docment.find("bdstoken") != docment.end() && docment["bdstoken"].is_string()){
            bdstoken = QString::fromStdString(docment["bdstoken"].get<std::string>());
        }
        qsUrl = QString(FILE_RENAME_URL).arg(bdstoken);
        //HttpRequest BaiduHttp;
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Referer",HOME_URL);
        QString data = QString("[{\"path\":\"%1\",\"newname\":\"%2\"}]").arg(name).arg(newName);
        data = urlCoding(data);
        QString sendData = "filelist=" + data;
        send(POST,qsUrl,sendData.toLatin1());
        auto qsJson = getBodyContent();
        if(qsJson.isEmpty()){
            return result;
        }
        json resultJosn = json::parse(qsJson.data());
        if(resultJosn.is_structured()){
            if(resultJosn.find("errno") != resultJosn.end() && resultJosn["errno"].is_number()){
                int errno = resultJosn["errno"].get<int>();
                if(!errno){
                    result = true;
                }
            }
        }
    }
    return result;
}

bool BaiduInterface::deleteFile(const QString &jsondata, const QString &path)
{
    bool result = false;
    if(jsondata.isEmpty() || path.isEmpty()){
        return result;
    }
    json docment = json::parse(jsondata.toStdString().c_str());
    if(docment.is_structured()){
        QString cookie,bdstoken,qsUrl;
        if(docment.find("cookie") != docment.end() && docment["cookie"].is_string()){
            cookie = QString::fromStdString(docment["cookie"].get<std::string>());
        }
        if(docment.find("bdstoken") != docment.end() && docment["bdstoken"].is_string()){
            bdstoken = QString::fromStdString(docment["bdstoken"].get<std::string>());
        }
        qsUrl = QString(FILE_DELETE_URL).arg(bdstoken);
        //HttpRequest BaiduHttp;
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Referer",HOME_URL);
        QString data = QString("[\"%1\"]").arg(path);
        data = urlCoding(data);
        QString sendData = "filelist=" + data;
        send(POST,qsUrl,sendData.toLatin1());
        auto qsJson = getBodyContent();
        if(qsJson.isEmpty()){
            return result;
        }
        json resultJosn = json::parse(qsJson.data());
        if(resultJosn.is_structured()){
            if(resultJosn.find("errno")!= resultJosn.end() && resultJosn["errno"].is_number()){
                int errno = resultJosn["errno"].get<int>();
                if(!errno){
                    result = true;
                }
            }
        }
    }
    return result;
}

bool BaiduInterface::moveCopyFile(const QString& jsondata,const QString &destPath, const QString &srcPath,bool type)
{
    bool bResult = false;
    if(jsondata.isEmpty() || destPath.isEmpty() || srcPath.isEmpty()){
        return bResult;
    }
    QString tDestPath,tJsonData,tSendJson;
    tDestPath = destPath;
    tJsonData = jsondata;
    if(tJsonData.isEmpty()){
        return bResult;
    }
    json docment = json::parse(tJsonData.toStdString().c_str());
    if(docment.is_structured()){
        QString bdstoken,RequestURL,tStrResult,tStrCookie,tStrSendData = "filelist=";
        if (docment.find("cookie") != docment.end() && docment["cookie"].is_string()) {
			tStrCookie = QString::fromStdString(docment["cookie"].get<std::string>());
		}
        if(docment.find("cookie") != docment.end() && docment["bdstoken"].is_string()){
            bdstoken = QString::fromStdString(docment["bdstoken"].get<std::string>());
            // 这里可以组装请求的数据包了
            json fileData = json::parse(srcPath.toStdString().c_str());
            if(!fileData.is_array()){
                return bResult;
            }
            //组装文件列表json数据
            json fileItem,fileArray;
            for(auto& v : fileData){
                QString tFileName,tSrcPath;
                if(v.is_object()){
                    if(v["path"].is_string()){
                        tSrcPath = QString::fromStdString(v["path"].get<std::string>());
                        QFileInfo fileinfo(tSrcPath);
                        tFileName = fileinfo.fileName();
                        fileItem["dest"] = tDestPath.toStdString();
                        fileItem["newname"] = tFileName.toStdString();
                        fileItem["path"] = tSrcPath.toStdString();
                        fileArray.push_back(fileItem);
                    }
                }
            }
            tSendJson = QString::fromStdString(fileArray.dump());
           // qDebug() << tSendJson << endl;
            tSendJson = urlCoding(tSendJson);
			tStrSendData += tSendJson;
          //  qDebug() << tSendJson << endl;
            int errno = 0;
            if(type){
                setRequestHeader("Cookie",tStrCookie);
				setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                setRequestHeader("Referer",HOME_URL);
                RequestURL = QString(FILE_MOVE_URL).arg(bdstoken);
				send(POST, RequestURL, tStrSendData.toLocal8Bit());
                tStrResult = getBodyContent();
                json resultJson = json::parse(tStrResult.toStdString().c_str());
                if(resultJson.is_object()){
                    if(resultJson.find("errno") != resultJson.end() && resultJson["errno"].is_number()){
                        errno = resultJson["errno"].get<int>();
                    }else{
                        errno = -1;
                    }
                }
            }else{
				setRequestHeader("Cookie", tStrCookie);
                setRequestHeader("Content-Type","application/x-www-form-urlencoded");
                setRequestHeader("Referer",HOME_URL);
                RequestURL = QString(FILE_COPY_URL).arg(bdstoken);
                send(POST,RequestURL, tStrSendData.toLocal8Bit());
                tStrResult = getBodyContent();
                json resultJson = json::parse(tStrResult.toStdString().c_str());
                if(resultJson.is_object()){
                    if(resultJson.find("errno") != resultJson.end() &&resultJson["errno"].is_number()){
                        errno = resultJson["errno"].get<int>();
                    }else{
                        errno = -1;
                    }
                }
            }
            if(!errno){
                //只有json返回结果是成功的时候才返回true
                 bResult = true;
            }
        }
    }
    return bResult;
}

QString BaiduInterface::shareFile(const QString &jsondata, const QString &fileList, bool isEncrypt, quint32 timeLimit)
{
    QString bResult = "";
    if(jsondata.isEmpty() || fileList.isEmpty()){
        return bResult;
    }
    //解析用户信息json数据
    json userDc = json::parse(jsondata.toStdString().c_str());
    QString tCookies,tBdstoken,tUrlData,tResult,szPassword;
    if(userDc.is_structured()){
		QString tSendData = "fid_list=[";
        if (userDc.find("cookie") != userDc.end() && userDc["cookie"].is_string()) {
            tCookies = QString::fromStdString(userDc["cookie"].get<std::string>());
        }else{
            return bResult;
        }
        if(userDc.find("bdstoken") != userDc.end() && userDc["bdstoken"].is_string()){
            tBdstoken = QString::fromStdString(userDc["bdstoken"].get<std::string>());
        }else{
            return bResult;
        }
		json fileDoc = json::parse(fileList.toStdString().c_str());
		if (!fileDoc.is_structured()) {
			return bResult;
		}
		for (auto& v : fileDoc)
		{
			if (v.is_number_unsigned()) {
				tSendData += QString::fromStdString(std::to_string(v.get<uint64_t>()));
				tSendData += ",";
			}
		}
		int pos = tSendData.lastIndexOf(",");
		if (-1 != pos) {
			tSendData = tSendData.left(pos);
		}
		tSendData += "]";
		if (!isEncrypt)
		{
			tSendData += "&schannel=0&channel_list=[]&period=%1";
			tSendData = tSendData.arg(timeLimit);
		}
		else
		{
			tSendData += "&schannel=4&channel_list=[]&period=%1&pwd=%2";
            szPassword = random();
			tSendData = tSendData.arg(timeLimit).arg(szPassword);
		}
		tSendData = urlCoding(tSendData);
		tSendData = tSendData.replace("%3D", "=");
		tSendData = tSendData.replace("%26", "&");
		setRequestHeader("User-Agent", USER_AGENT);
		setRequestHeader("Cookie", tCookies);
		setRequestHeader("Referer", HOME_URL);
		tUrlData = QString(FILE_SHARE_URL).arg(tBdstoken);
		send(POST, tUrlData, tSendData.toLocal8Bit());
		tResult = getBodyContent();
        json docment = json::parse(tResult.toStdString().c_str());
        int errno = -1;
        if(docment.is_structured()){
            if(docment.find("errno") != docment.end() && docment["errno"].is_number()){
                errno =  docment["errno"].get<int>();
                if(!errno){
                    if(docment.find("link") != docment.end() && docment["link"].is_string()){
                        tResult = QString::fromStdString(docment["link"].get<std::string>());
                        if(isEncrypt){
							bResult = QStringLiteral("链接: ") + tResult + QStringLiteral(" 提取码: ") + szPassword;
							//QTextCodec* utf8 = QTextCodec::codecForName("UTF-8");

                        }else{
                            bResult = tResult;
                        }
                    }
                }
            }
        }
        qDebug() << tResult << endl << bResult << endl;
    }

    return bResult;
}

QString BaiduInterface::parseDownloadUrl(const QString& shareUrl,const QString& seCode,const QString& password,const QString& cookie)
{
    QString result = "{}"; // 失败返回空json 对象
    int statusCode = 0;
    if(shareUrl.isEmpty()){
        //解析的url如果是空的 就是瞎扯返回
        return result;
    }
    if(!password.isEmpty() && !cookie.isEmpty()){
        //如果密码和cookie 都不为空 那就完全证明这个地址是带访问密码的
        QUrl szUrl(shareUrl);
        QFileInfo info(szUrl.path());
        QString surl = info.fileName();
        surl = surl.mid(1);
        qDebug() << surl << endl;
        QString strUrl = QString(FILE_SEND_PASSWORD_URL).arg(surl);
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Accept","*/*");
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        setRequestHeader("Referer",HOME_URL);
        QString szData = "pwd=" + password;
        send(POST,strUrl,szData.toLocal8Bit());
        szData = getBodyContent();
        statusCode = getStatusCode();
        QString strCookie = mergeCookie(getCookie(),cookie);
        if(statusCode == 200 && !strCookie.isEmpty()){
            json doc = json::parse(szData.toStdString().c_str());
            if(doc.is_structured()){
                if(doc.find("errno")!= doc.end() && doc["errno"].is_number()){
                    int error_num = doc["errno"].get<int>();
                    if(!error_num){
                        setRequestHeader("User-Agent",USER_AGENT);
                        setRequestHeader("Accept","*/*");
                        setRequestHeader("Cookie",strCookie);
                        send(GET,shareUrl);
                        szData = getBodyContent();
                        statusCode = getStatusCode();
                        strCookie = mergeCookie(getCookie(),strCookie);
                        if(statusCode == 200){
                            QRegExp userRegex("yunData\\.setData\\((.*)\\);");
                            userRegex.setMinimal(true);
                            if (!userRegex.isValid())
                            {
                                return result;
                            }
                            int pos = userRegex.indexIn(szData);
                            if(pos > -1){
                                szData = userRegex.cap(1);
                               result = getShareFileInfo(strCookie,szData);
                            }
                        }else{
                            //发送信号表示这个文件不存在
                            emit showMessage(QStringLiteral("文件存在非法信息已经被删除或该分享文件已过期"));
                        }
                    }else{
                        emit inputPassword(shareUrl,cookie);
                    }
                }
            }
        }

    }else{
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Accept","*/*");
        send(GET,shareUrl);
        statusCode = getStatusCode();
        QString strCookie = getCookie();
        QString szData = getBodyContent();
        if(statusCode == 302 || statusCode == 301){
            QString strHeaders = getHeaders();
            int pos = strHeaders.indexOf("Location:");
            if(pos!=-1){
                emit inputPassword(shareUrl,strCookie);
            }
        }else if(statusCode == 200){
            QRegExp userRegex("yunData\\.setData\\((.*)\\);");
            userRegex.setMinimal(true);
            if (!userRegex.isValid())
            {
                return result;
            }
            int pos = userRegex.indexIn(szData);
            if(pos > -1){
                szData = userRegex.cap(1);
                result = getShareFileInfo(strCookie,szData);
            }
        }
    }
    if(!seCode.isEmpty() && !cookie.isEmpty()){
       //如果验证码和cookie 都不为空 那就完全证明这个地址访问太频繁需要输入验证码了
    }
    return result;
}

QString BaiduInterface::getShareFilePath(const QString &cookie, const QString &path, const QString &shareid, const QString &uk)
{
    QString result = "{}";
    if(cookie.isEmpty() || path.isEmpty() || shareid.isEmpty() || uk.isEmpty()){
        emit showMessage(QStringLiteral("无效的cookie信息!错误代码0x0001250"));
        return result;
    }
    setRequestHeader("User-Agent",USER_AGENT);
    setRequestHeader("Accept","*/*");
    setRequestHeader("Cookie",cookie);
    setRequestHeader("Referer",HOME_URL);
    QString shareUrl = QString(PATH_SHARE_LIST_PATH).arg(shareid).arg(uk).arg(urlCoding(path));
    send(GET,shareUrl);
    QString szData = getBodyContent();
    int dwStatusCode = getStatusCode();
    json dumpJson;
    if(dwStatusCode == 200){
        json dataDoc = json::parse(szData.toStdString().c_str());
        if(dataDoc.find("list")!= dataDoc.end() && dataDoc["list"].is_array())
        {
              json resultArr;
              for(auto& v: dataDoc["list"]){
                  uint isdir = 0;
                  if(v.is_object()){
                      json itemJson;
                      if(v.find("server_filename")!= v.end() && v["server_filename"].is_string()){
                          itemJson["name"] = v["server_filename"].get<std::string>();
                      }
                      if(v.find("server_filename")!= v.end() && v["server_filename"].is_number_unsigned()){
                          itemJson["name"] = v["server_filename"].get<uint64_t>();
                      }
                      if(v.find("path")!= v.end() && v["path"].is_string()){
                          itemJson["path"] = v["path"].get<std::string>();
                      }
                      if(v.find("isdir")!= v.end() && v["isdir"].is_string()){
                          isdir = atoi(v["isdir"].get<std::string>().c_str());
                          itemJson["isdir"] = isdir;
                      }
                      if(v.find("server_ctime") != v.end() && v["server_ctime"].is_string()){
                          uint64_t time = _atoi64(v["server_ctime"].get<std::string>().c_str());
                          itemJson["timer"] =  QDateTime::fromTime_t(qint64(time)).toString("yyyy-MM-dd HH:mm:ss").toStdString();
                      }
                      if(v.find("server_ctime") != v.end() && v["server_ctime"].is_number_unsigned()){
                          uint64_t time = v["server_ctime"].get<uint64_t>();
                          itemJson["timer"] =  QDateTime::fromTime_t(qint64(time)).toString("yyyy-MM-dd HH:mm:ss").toStdString();
                      }
                      if(v.find("size") != v.end() && v["size"].is_string()){
                          uint64_t size = _atoi64(v["size"].get<std::string>().c_str());
                          itemJson["size"] = size > 0 ? formatFileSize(size).toStdString() : "-";
                      }
                      if(v.find("size") != v.end() && v["size"].is_number_unsigned()){
                          uint64_t size = v["size"].get<uint64_t>();
                          itemJson["size"] = size > 0 ? formatFileSize(size).toStdString() : "-";
                      }
                      if (v.find("fs_id") != v.end() && v["fs_id"].is_string()) {
                          uint64_t fs_id = _atoi64(v["fs_id"].get<std::string>().c_str());
                          itemJson["fs_id"] = fs_id;
                      }
                      if (v.find("fs_id") != v.end() && v["fs_id"].is_number_unsigned()) {
                          uint64_t fs_id = v["fs_id"].get<uint64_t>();
                          itemJson["fs_id"] = fs_id;
                      }
                      if(isdir){
                          itemJson["type"] = "folder";
                      }else{
                          std::string filePath = itemJson["path"].get<std::string>();
                          QFileInfo info(filePath.c_str());
                          QString suffix = info.suffix();
                          QString path = QString(":/images/%1.png").arg(suffix);
                          if(checkFileExist(path)){
                              itemJson["type"] = suffix.toStdString();
                          }else{
                              itemJson["type"] = "old";
                          }
                      }
                      itemJson["check"] = false;
                      resultArr.push_back(itemJson);
                  }

              }
              dumpJson["list"] = resultArr;
       }
    }
    result = QString::fromStdString(dumpJson.dump());
    return result;
}

QString BaiduInterface::getDownloadShareInfo(const QString &jsonData, const QString &verificationCode)
{
    QString result = "{}";
    if(jsonData.isEmpty()){
        return result;
    }
    json parseDc = json::parse(jsonData.toStdString().c_str());
    if(!parseDc.is_structured()){
        emit showMessage(QStringLiteral("提供的文件信息不完整无法解析真实下载地址"));
        return result;
    }
    QString cookie,shareid,uk,sendData,sign;
    if(parseDc.find("Cookie")!= parseDc.end() && parseDc["Cookie"].is_string()){
        cookie = QString::fromStdString(parseDc["Cookie"].get<std::string>());
    }else{
        emit showMessage(QStringLiteral("Cookie 无效....有BUG...."));
        return result;
    }
    if(parseDc.find("shareid")!= parseDc.end() && parseDc["shareid"].is_string()){
        shareid = QString::fromStdString(parseDc["shareid"].get<std::string>());
    }else{
        emit showMessage(QStringLiteral("shareid 无效....有BUG...."));
        return result;
    }
    if(parseDc.find("sign")!= parseDc.end() && parseDc["sign"].is_string()){
        sign = QString::fromStdString(parseDc["sign"].get<std::string>());
    }else{
        emit showMessage(QStringLiteral("sign 无效....有BUG...."));
        return result;
    }
    if(parseDc.find("uk")!= parseDc.end() && parseDc["uk"].is_string()){
        uk = QString::fromStdString(parseDc["uk"].get<std::string>());
    }else{
        emit showMessage(QStringLiteral("uk 无效....有BUG...."));
        return result;
    }
    QString seKey = getCookieValue(cookie,"BDCLND");
    seKey = QByteArray::fromPercentEncoding(seKey.toLocal8Bit());
    if(seKey.isEmpty()){
        emit showMessage(QStringLiteral("seKey 无效....有BUG...."));
        return result;
    }
    QStringList downloadListFsId;
    if(parseDc.find("list")!=parseDc.end() && parseDc["list"].is_array()){
        for(auto& v : parseDc["list"]){
             downloadListFsId << QString("%1").arg(v.get<uint64_t>());
        }
    }
    QString fs_id_array = downloadListFsId.join(",");
    sendData = "encrypt=0&extra=" + QString("{\"sekey\":\"%1\"}").arg(seKey).toLocal8Bit().toPercentEncoding();
    QString sendData2 = QString("&fid_list=[%1]&primaryid=%2&product=share&uk=%3").arg(fs_id_array).arg(shareid).arg(uk);
    if(verificationCode.isEmpty()){
        //如果验证码是空的 那就是没有需要输入验证码的
        QString data = sendData;
        data += sendData2.toLocal8Bit().toPercentEncoding("&=");
        QString uri = QString(DOWNLOAD_FILE_INFO).arg(sign).arg(QString::fromStdString(std::to_string((ulong)QDateTime::currentMSecsSinceEpoch())));
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Accept","*/*");
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        setRequestHeader("Referer",HOME_URL);
        send(POST,uri,data.toLocal8Bit());
        QString sResult = getBodyContent();
        json resultParse = json::parse(sResult.toStdString().c_str());
        if(!resultParse.is_structured()){
            emit showMessage(QStringLiteral("解析下载地址失败 无效的json数据....有BUG...."));
            return result;
        }
        int errno = 0;
        if(resultParse.find("errno")!= resultParse.end() && resultParse["errno"].is_number()){
            json retJson;
            errno = resultParse["errno"].get<int>();
            if(!errno){
                if(resultParse.find("list")!= resultParse.end() && resultParse["list"].is_array()){
                    json retArray;
                    for(auto & val :resultParse["list"]){
                        json itemUri;
                        if(val.is_object()){
                            if(val.find("dlink") != val.end() && val["dlink"].is_string()){
                                itemUri["url"] = val["dlink"].get<std::string>();
                            }
                            retArray.push_back(itemUri);
                        }
                    }
                    retJson["list"] = retArray;
                    result = QString::fromStdString(retJson.dump());
                }
            }else{
                //发送输入验证码信号
                emit inputverCode(jsonData);
            }
        }

    }else{
        //否则就是需要输入验证码
        QString vcCode,password;
        json vcCodeJosn = json::parse(verificationCode.toStdString().c_str());
        if(!vcCodeJosn.is_structured()){
            emit showMessage(QStringLiteral("验证码json信息不完整"));
            //发送输入验证码信号
            emit inputverCode(jsonData);
            return result;
        }
        if(vcCodeJosn.find("vcode") != vcCodeJosn.end() && vcCodeJosn["vcode"].is_string()){
            vcCode = QString::fromStdString(vcCodeJosn["vcode"].get<std::string>());
        }else{
            emit showMessage(QStringLiteral("验证码vcode信息不存在"));
            //发送输入验证码信号
            emit inputverCode(jsonData);
            return result;
        }
        if(vcCodeJosn.find("input") != vcCodeJosn.end() && vcCodeJosn["input"].is_string()){
            password = QString::fromStdString(vcCodeJosn["input"].get<std::string>());
        }else{
             emit showMessage(QStringLiteral("验证码input信息不存在"));
            //发送输入验证码信号
            emit inputverCode(jsonData);
            return result;
        }
        QString data = sendData;
        data += sendData2.toLocal8Bit().toPercentEncoding("&=");
        data += QString("&vcode_input=%1&vcode_str=%2").arg(password).arg(vcCode);
        QString uri = QString(DOWNLOAD_FILE_INFO).arg(sign).arg(QString::fromStdString(std::to_string((ulong)QDateTime::currentMSecsSinceEpoch())));
        setRequestHeader("User-Agent",USER_AGENT);
        setRequestHeader("Accept","*/*");
        setRequestHeader("Cookie",cookie);
        setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        setRequestHeader("Referer",HOME_URL);
        send(POST,uri,data.toLocal8Bit());
        QString sResult = getBodyContent();
        json resultParse = json::parse(sResult.toStdString().c_str());
        if(!resultParse.is_structured()){
            emit showMessage(QStringLiteral("解析下载地址失败 无效的json数据....有BUG...."));
            return result;
        }
        int errno = 0;
        if(resultParse.find("errno")!= resultParse.end() && resultParse["errno"].is_number()){
            json retJson;
            errno = resultParse["errno"].get<int>();
            if(!errno){
                if(resultParse.find("list")!= resultParse.end() && resultParse["list"].is_array()){
                    json retArray;
                    for(auto & val :resultParse["list"]){
                        json itemUri;
                        if(val.is_object()){
                            if(val.find("dlink") != val.end() && val["dlink"].is_string()){
                                itemUri["url"] = val["dlink"].get<std::string>();
                            }
                            retArray.push_back(itemUri);
                        }
                    }
                    retJson["list"] = retArray;
                    result = QString::fromStdString(retJson.dump());
                }
            }else{
                //发送输入验证码信号
                emit inputverCode(jsonData);
            }
        }
    }
    return result;
}

QString BaiduInterface::getVcVode()
{
    QString result = "{}";
    setRequestHeader("User-Agent",USER_AGENT);
    setRequestHeader("Accept","*/*");
    setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    setRequestHeader("Referer",HOME_URL);
    send(GET,DOWNLOAD_VCCODE_URI);
    result = getBodyContent();
    return result;

}

QString BaiduInterface::getShareFileInfo(const QString &cookie, const QString &jsonData)
{
    QString result;
    if(cookie.isEmpty()){
        emit showMessage(QStringLiteral("无效的cookie信息!错误代码0x0001250"));
        return result;
    }
    json dataDoc = json::parse(jsonData.toStdString().c_str());
    json dumpJson;
    QString shareid,uk;
    if(dataDoc.is_structured()){
        if(dataDoc.find("uk") != dataDoc.end() && dataDoc["uk"].is_number_unsigned()){
            uk = QString("%1").arg(dataDoc["uk"].get<uint64_t>());
            dumpJson["uk"] = uk.toStdString();
        }
        if(dataDoc.find("shareid") != dataDoc.end() && dataDoc["shareid"].is_number_unsigned()){
            shareid = QString("%1").arg(dataDoc["shareid"].get<uint64_t>());
            dumpJson["shareid"] = shareid.toStdString();

        }
        if(dataDoc.find("sign") != dataDoc.end() && dataDoc["sign"].is_string()){
            dumpJson["sign"] = dataDoc["sign"].get<std::string>();
        }
        dumpJson["Cookie"] = cookie.toStdString();
        if(dataDoc.find("file_list")!=dataDoc.end() && dataDoc["file_list"].is_object()){
            setRequestHeader("User-Agent",USER_AGENT);
            setRequestHeader("Accept","*/*");
            setRequestHeader("Cookie",cookie);
            setRequestHeader("Referer",HOME_URL);
            QString shareUrl = QString(PATH_SHARE_LIST_INFO).arg(shareid).arg(uk);
            send(GET,shareUrl);
            QString szData = getBodyContent();
            int dwStatusCode = getStatusCode();
            if(dwStatusCode == 200){
                dataDoc = json::parse(szData.toStdString().c_str());
                if(dataDoc.find("title")!= dataDoc.end() && dataDoc["title"].is_string()){
                    dumpJson["title"] = dataDoc["title"].get<std::string>();
                }
                if(dataDoc.find("list")!= dataDoc.end() && dataDoc["list"].is_array())
                {
                      json resultArr;
                      for(auto& v: dataDoc["list"]){
                          uint isdir = 0;
                          if(v.is_object()){
                              json itemJson;
                              if(v.find("server_filename")!= v.end() && v["server_filename"].is_string()){
                                  itemJson["name"] = v["server_filename"].get<std::string>();
                              }
                              if(v.find("server_filename")!= v.end() && v["server_filename"].is_number_unsigned()){
                                  itemJson["name"] = v["server_filename"].get<uint64_t>();
                              }
                              if(v.find("path")!= v.end() && v["path"].is_string()){
                                  itemJson["path"] = v["path"].get<std::string>();
                              }
                              if(v.find("isdir")!= v.end() && v["isdir"].is_string()){
                                  isdir = atoi(v["isdir"].get<std::string>().c_str());
                                  itemJson["isdir"] = isdir;
                              }
                              if(v.find("server_ctime") != v.end() && v["server_ctime"].is_string()){
                                  uint64_t time = _atoi64(v["server_ctime"].get<std::string>().c_str());
                                  itemJson["timer"] =  QDateTime::fromTime_t(qint64(time)).toString("yyyy-MM-dd HH:mm:ss").toStdString();
                              }
                              if(v.find("server_ctime") != v.end() && v["server_ctime"].is_number_unsigned()){
                                  uint64_t time = v["server_ctime"].get<uint64_t>();
                                  itemJson["timer"] =  QDateTime::fromTime_t(qint64(time)).toString("yyyy-MM-dd HH:mm:ss").toStdString();
                              }
                              if(v.find("size") != v.end() && v["size"].is_string()){
                                  uint64_t size = _atoi64(v["size"].get<std::string>().c_str());
                                  itemJson["size"] = size > 0 ? formatFileSize(size).toStdString() : "-";
                              }
                              if(v.find("size") != v.end() && v["size"].is_number_unsigned()){
                                  uint64_t size = v["size"].get<uint64_t>();
                                  itemJson["size"] = size > 0 ? formatFileSize(size).toStdString() : "-";
                              }
                              if (v.find("fs_id") != v.end() && v["fs_id"].is_string()) {
                                  uint64_t fs_id = _atoi64(v["fs_id"].get<std::string>().c_str());
                                  itemJson["fs_id"] = fs_id;
                              }
                              if (v.find("fs_id") != v.end() && v["fs_id"].is_number_unsigned()) {
                                  uint64_t fs_id = v["fs_id"].get<uint64_t>();
                                  itemJson["fs_id"] = fs_id;
                              }
                              if(isdir){
                                  itemJson["type"] = "folder";
                              }else{
                                  std::string filePath = itemJson["path"].get<std::string>();
                                  QFileInfo info(filePath.c_str());
                                  QString suffix = info.suffix();
                                  QString path = QString(":/images/%1.png").arg(suffix);
                                  if(checkFileExist(path)){
                                      itemJson["type"] = suffix.toStdString();
                                  }else{
                                      itemJson["type"] = "old";
                                  }
                              }
                              itemJson["check"] = false;
                              resultArr.push_back(itemJson);
                          }

                      }
                      dumpJson["list"] = resultArr;
               }
            }
        }else{
            //发送信号表示这个文件不存在
            emit showMessage(QStringLiteral("文件存在非法信息已经被删除或该分享文件已过期"));
        }
        result = QString::fromStdString(dumpJson.dump());
    }
    return result;
}

QString BaiduInterface::formatFileSize(uint64_t size)
{
    QString result;
    if (size <1024)
    {
        result = QString("%1 B").arg(double(size),0,'f',1);
    }
    else if (size >1024 && size < 1024 * 1024 * 1024 && size <1024 * 1024)
    {
        result = QString("%1 KB").arg(double(double(size) / 1024),0,'f',1);
    }
    else if (size >1024 * 1024 && size <1024 * 1024 * 1024)
    {
        result = QString("%1 MB").arg(double(double(size) / 1024 / 1024),0,'f',1);
    }
    else if (size >1024 * 1024 * 1024)
    {
        result  = QString("%1 GB").arg(double(double(size) / 1024 / 1024 / 1024),0,'f',1);
    }
    return result;
}

bool BaiduInterface::checkFileExist(const QString &filePath)
{
    bool result = false;
    if(filePath.isEmpty()){
        return result;
    }
    QFileInfo info(filePath);
    result = (info.exists() && info.isFile());
    return result;
}


