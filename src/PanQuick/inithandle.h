#ifndef INITHANDLE_H
#define INITHANDLE_H

#include <QObject>
#include "initthread.h"
class InitHandle : public QObject
{
    Q_OBJECT
public:
    explicit InitHandle(InitThread* InitThreadPtr);

    Q_INVOKABLE void start();
signals:

public slots:
private:
    InitThread* m_InitThreadPtr;
};

#endif // INITHANDLE_H
