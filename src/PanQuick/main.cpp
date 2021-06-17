#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <qtwebengineglobal.h>
#include "detector.h"
#include "inithandle.h"
#include "systemtaryicon.h"
#include "cookiemangre.h"
#include "baiduinterface.h"
#include "treeviewmodel.h"
#include "systeminterface.h"
int main(int argc, char *argv[])
{

    QApplication app(argc, argv);
    int rResult = 0;
    QQmlApplicationEngine engine;
    QtWebEngine::initialize();
    qmlRegisterType<ActionItem>("an.utility",1,0,"ActionItem");
    qmlRegisterType<SeparatorItem>("an.utility",1,0,"SeparatorItem");
    qmlRegisterType<TaryMenu>("an.utility",1,0,"TaryMenu");
    qmlRegisterType<SystemTaryIcon>("an.utility",1,0,"SystemTaryIcon"); //托盘
    auto context = engine.rootContext(); // qml 上下文环境
    auto detector = new Detector();     // 启动检测
    auto inithandle = new InitHandle(new InitThread(detector)); //工作线程
    auto baidu = new BaiduInterface();  // 百度 api接口
    auto cookiemangre = new CookieMangre(); //cookie 管理
    auto systeminterface = new SystemInterface; //系统操作相关
    qmlRegisterUncreatableType<TreeViewModel>("model.treeModel", 1, 0,
                                                       "treeModel", "Cannot create a treeModel instance."); //树形列表model
    TreeViewModel* fsm = new TreeViewModel(&engine);
    context->setContextProperty("treeViewModel", fsm);
    context->setContextProperty("detector",detector);
    context->setContextProperty("initHandle",inithandle);
    context->setContextProperty("cookiemangre",cookiemangre);
    context->setContextProperty("baidu",baidu);
    context->setContextProperty("System",systeminterface);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.load(QUrl(QStringLiteral("qrc:/panview.qml")));

    rResult = app.exec();
    delete fsm;
    delete baidu;
    delete cookiemangre;
    delete detector;
    delete inithandle;
    return rResult;
}
