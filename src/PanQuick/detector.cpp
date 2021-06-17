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
#include <QTimer>
#include <QTcpServer>
Detector::Detector(QObject *parent) : QObject(parent)
  ,m_version("1.0.0")
  ,m_isUpdate(false)
{
    m_httpManager = new QNetworkAccessManager(this);

}

void Detector::run()
{
    //启动程序准备
    //第一步 检查是否需要更新
    emit updateStatus(QStringLiteral("正在连接到服务器..."));
    isUpdate();
    emit isupdate(m_isUpdate);
    //第二步启动aria2
    emit updateStatus(QStringLiteral("正在初始化下载引擎..."));
    if(!startAria2()){
        emit updateStatus(QStringLiteral("初始化下载引擎失败 请尝试重新启动"));
        emit show("main");
        emit updateError(true); // 失败了 需要 更新 动画效果
        return;
    }
    emit updateStatus(QStringLiteral("准备进入"));
    emit show("quick");
}

quint16 Detector::getPort() const
{
    return mPort;
}

bool Detector::isUpdate()
{
    emit updateStatus(QStringLiteral("正在检测是否有新版本..."));
    m_isUpdate = checkIsUpdate();
    return m_isUpdate;
}

quint16 Detector::getLocalPort()
{
    quint16 Port = 6800;
    QTcpServer Server;
    if(Server.listen()){
        Port = Server.serverPort();
        Server.close();
        mPort = Port;
    }
    return Port;
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
    //防止一直无限等待可以使用超时机制 60秒还没结果就调用quit
    QTimer::singleShot(60000,&loop,&QEventLoop::quit);
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
    //这里解析服务器那边给出的版本比较结果返回作为是否更新的依赖
    return bResult;
}

bool Detector::startAria2()
{
    bool bResult = false;
    QProcess* process = new QProcess(this);
    QString strProgramName = QDir::currentPath() + "/aria2c.exe";
    QStringList arguments;
	qint64 processId = GetCurrentProcessId();
    qDebug()<< strProgramName << endl;
    mPort = getLocalPort();
#if _DEBUG
    arguments << "--check-certificate=false" << "--continue=true" << "--disable-ipv6=true" \
              << "--enable-rpc=true" << "--quiet=false" << "--file-allocation=trunc" << "--max-concurrent-downloads=5" \
              << "--rpc-allow-origin-all=true" << "--rpc-listen-all=true" << QString("--rpc-listen-port=%1").arg(mPort) \
              << "--rpc-secret=PanQuick" << QString("--stop-with-process=%2").arg(processId);
#else
    arguments << "--check-certificate=false" << "--continue=true" << "--disable-ipv6=true" \
              << "--enable-rpc=true" << "--quiet=true" << "--file-allocation=trunc" << "--max-concurrent-downloads=5" \
              << "--rpc-allow-origin-all=true" << "--rpc-listen-all=true" << QString("--rpc-listen-port=%1").arg(mPort) \
              << "--rpc-secret=PanQuick" << QString("--stop-with-process=%1").arg(processId);
#endif
    process->setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *args){
        qDebug() << "CreateProcessArguments" << endl;
        args->flags |= CREATE_NEW_CONSOLE;
        args->startupInfo->dwFlags = STARTF_USESHOWWINDOW;
#if _DEBUG
        args->startupInfo->wShowWindow = SW_SHOW;
#else
        args->startupInfo->wShowWindow = SW_HIDE;
#endif
    });
    process->start(strProgramName,arguments);
    bResult =  process->waitForStarted();

    return bResult;
}




















