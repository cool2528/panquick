#ifndef SYSTEMINTERFACE_H
#define SYSTEMINTERFACE_H

#include <QObject>
/*
@ 主要封装一些系统操作的功能为QML其他组件提供支持
*/
class SystemInterface : public QObject
{
    Q_OBJECT
public:
    explicit SystemInterface(QObject *parent = 0);
/*
 * 剪切板操作
 * 复制剪切板内容Cl
*/
    Q_INVOKABLE QString getClipboard();
/*
 * 剪切板操作
 * 设置剪切板内容
*/
    Q_INVOKABLE void setClipboard(const QString& text);
signals:

public slots:
};

#endif // SYSTEMINTERFACE_H
