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
    Q_INVOKABLE bool isUpdate();
    Q_PROPERTY(QString version READ version WRITE setVersion)
signals:
    //显/隐/主子窗口
    void show(QString show);
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
private:
    //发起一个Get请求 返回请求的Text文本数据 简单的为了取新版本信息
    QString get(const QString url);
    //检测是否需要更新
    bool checkIsUpdate();
    //启动aria2
    bool startAria2();

};

#endif // DETECTOR_H
