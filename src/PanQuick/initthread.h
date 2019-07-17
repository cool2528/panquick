#ifndef INITTHREAD_H
#define INITTHREAD_H
#include<QThread>
#include "detector.h"
class InitThread : public QThread
{
    Q_OBJECT
public:
    explicit InitThread();
    explicit InitThread(Detector* detector);
protected:
    virtual void run();
private:
    Detector* m_detector;
};

#endif // INITTHREAD_H
