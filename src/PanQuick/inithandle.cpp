#include "inithandle.h"

InitHandle::InitHandle(InitThread* InitThreadPtr)
{
    m_InitThreadPtr = InitThreadPtr;
}

void InitHandle::start()
{
    m_InitThreadPtr->start();
}
