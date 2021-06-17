#ifndef DETECTOR_H
#define DETECTOR_H
#include <QObject>
class QNetworkAccessManager;
class Detector : public QObject
{
    Q_OBJECT
#define UPDATE_HOME_URL "http://127.0.0.1/?version=%1"
public:
    explicit Detector(QObject *parent = 0);
    Q_INVOKABLE void run();
    Q_PROPERTY(QString version READ version WRITE setVersion)
    Q_INVOKABLE quint16 getPort() const;
signals:
    //显/隐/主子窗口
    void show(QString show);
    //更新状态
    void updateStatus(QString status);
    //是否需要更新 true 更新
    void isupdate(bool flag);
    //更新错误状态
    void updateError(bool errorflag);
public slots:
private:
    QNetworkAccessManager* m_httpManager;   //http请求管理
    //软件版本
    QString m_version;
    //是否更新
    bool  m_isUpdate;
public:
    QString version() const;
    void setVersion(const QString& version);
    bool isUpdate();
    quint16 getLocalPort();
private:
    //发起一个Get请求 返回请求的Text文本数据 简单的为了取新版本信息
    QString get(const QString url);
    //检测是否需要更新
    bool checkIsUpdate();
    //启动aria2
    bool startAria2();
    quint16 mPort;  //aria2 port

};

#endif // DETECTOR_H
