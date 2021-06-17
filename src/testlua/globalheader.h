#ifndef GLOBALHEADER_H
#define GLOBALHEADER_H
#include <QString>
#include <QMap>
typedef struct httpinfo{
QString qsUrl;
QMap<QString,QString> mHeaders;
}HTTPINFO,*PHTTPINFO;

#endif // GLOBALHEADER_H
