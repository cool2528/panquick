#include <QCoreApplication>
#include "panquickkernel.h"
#include <QFile>
#include <QTextStream>
#include <iostream>
#include "globalheader.h"
using namespace std;

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
#if 0
    PanQuickKernel kernel;
    QString data;
    QFile file("E:\\VS2015\\QTcode\\project\\src\\testlua\\parse.lua");
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        cout << "open file falled" << endl;
        return 0;
    }
    QTextStream in(&file);
    data = in.readAll();
    file.close();
    HTTPINFO info;
    info.qsUrl = "%2FdnSpy.zip";
    info.mHeaders["Cookie"] = "BAIDUID=E1E7CB3379DE642EEADA16717B1D5C25:FG=1; BDUSS=Y4WURiU1R4UnE4alY5ekwtRE14Y1ZhWjVPZmhxSkhkLURCR1phTXFPMnUtZFJkSUFBQUFBJCQAAAAAAAAAAAEAAAB5~ROczOz0pdb6ytYzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAK5srV2ubK1dVj; PANWEB=1; STOKEN=61fa8f087d44e43279f74c8b1e798521be4788911d6cda00c1e41aedee18a29d; SCRC=6dc8a99dbe8ae8c36c447c48a7ae6c32; PANPSC=8729664739249637732%3AHSTAF2XekfpSGT8Pmo2ftHlibiKzYuqjXDZeu16eB4EY2BX9jg0If7R9Q74UEoJdbO2AoPFphFITOHQ48QXZaW5JWXvdyi5vEhyqVs%2B2HQGhdffKqBGRN9NRP5A5EemHkL2qAeJq7%2BV1Lxzud0jMsTEZmK5RR4JqhfSnrP2UPxXuD7k8za9a6w%3D%3D";
    info.mHeaders["bdstoken"] = "4508e1a71c9bf71253ab35c8fb637bbc";
    kernel.executeScript("interior", data,&info);
#endif
      PanQuickKernel kernel;
      kernel.loadScript("E:\\VS2015\\QTcode\\project\\src\\testlua\\parse.lua");
      kernel.test();
    return a.exec();
}
