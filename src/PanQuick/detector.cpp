#include "detector.h"
#include <windows.h>
#include <QNetworkAccessManager>
#include <QSslConfiguration>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QEventLoop>
#include <QProcess>
#include <QDir>
#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
Detector::Detector(QObject *parent) : QObject(parent)
  ,m_version("1.0.0")
  ,m_isUpdate(false)
{
    m_httpManager = new QNetworkAccessManager(this);

}

void Detector::run()
{
    //启动程序准备
}

bool Detector::isUpdate()
{
    return m_isUpdate;
}

QString Detector::version() const
{
    return m_version;
}

void Detector::setVersion(const QString& version)
{
    m_version = version;
}

QString Detector::get(const QString url)
{
    QString strResult;
    if(url.isEmpty())
        return strResult;
	QUrl qURL(url);
	QNetworkRequest quest(qURL);
    QSslConfiguration config;
    config.setPeerVerifyMode(QSslSocket::VerifyNone);
    config.setProtocol(QSsl::TlsV1SslV3);
    quest.setSslConfiguration(config);
    auto reply = m_httpManager->get(quest);
    QEventLoop loop;
    connect(reply,&QNetworkReply::finished,&loop,&QEventLoop::quit);
    loop.exec();
    if(QNetworkReply::NoError == reply->error()){
        strResult = reply->readAll().data();
    }
    reply->deleteLater();
    return strResult;
}

bool Detector::checkIsUpdate()
{
    bool bResult = false;
    QString strUpdateValue = get(QString(UPDATE_HOME_URL).arg(m_version));
    QJsonParseError parseError;
    QJsonDocument dc = QJsonDocument::fromJson(strUpdateValue.toLocal8Bit(),&parseError);
    if(dc.isNull() || !dc.isObject())
        return bResult;

    return bResult;
}

bool Detector::startAria2()
{
    QProcess process;
    QString strProgramName = QDir::currentPath() + "aria2.exe";
    QStringList arguments;
	qint64 processId = GetCurrentProcessId();
    arguments << "--check-certificate=false" << "--continue=true" << "--disable-ipv6=true" \
              << "--enable-rpc=true" << "--quiet=true" << "--file-allocation=falloc" << "--max-concurrent-downloads=5" \
              << "--rpc-allow-origin-all=true" << "--rpc-listen-all=true" << "--rpc-listen-port=6810" \
              << "--rpc-secret=PanQuick" << QString("--stop-with-process=%1").arg(processId);

    process.setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *args){
        args->flags |= CREATE_NEW_CONSOLE;
        args->startupInfo->dwFlags = STARTF_USESHOWWINDOW;
        args->startupInfo->wShowWindow = SW_SHOW;
    });
    process.start(strProgramName,arguments);
    return process.waitForFinished();
}




















