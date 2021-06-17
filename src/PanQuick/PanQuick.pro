TEMPLATE = app

QT += qml quick network webengine widgets
CONFIG += c++11
RC_ICONS = app.ico
INCLUDEPATH += $$PWD/../../include
DEPENDPATH  += $$PWD/../../include
SOURCES += main.cpp \
    initthread.cpp \
    detector.cpp \
    inithandle.cpp \
    systemtaryicon.cpp \
    httprequest.cpp \
    cookiemangre.cpp \
    baiduinterface.cpp \
    treeitem.cpp \
    treeviewmodel.cpp \
    systeminterface.cpp

RESOURCES += qml.qrc \
    resource.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    initthread.h \
    detector.h \
    inithandle.h \
    systemtaryicon.h \
    httprequest.h \
    cookiemangre.h \
    baiduinterface.h \
    treeitem.h \
    treeviewmodel.h \
    systeminterface.h

DISTFILES +=

# 高DPI 自适应
QT_AUTO_SCREEN_SCALE_FACTOR = 1
