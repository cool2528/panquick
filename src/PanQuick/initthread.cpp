#include "initthread.h"

InitThread::InitThread()
{

}

InitThread::InitThread(Detector *detector)
{
    m_detector = detector;
}

void InitThread::run()
{
    //线程执行
}
