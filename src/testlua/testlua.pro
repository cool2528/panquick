QT += core network
QT -= gui

CONFIG += c++11

TARGET = testlua
CONFIG += console
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp \
    httprequest.cpp \
    panquickkernel.cpp



win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../lib/ -llua53
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../lib/ -llua53d

INCLUDEPATH += $$PWD/../../include/lua
DEPENDPATH += $$PWD/../../include/lua

win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$PWD/../../lib/liblua53.a
else:win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$PWD/../../lib/liblua53d.a
else:win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$PWD/../../lib/lua53.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$PWD/../../lib/lua53d.lib

HEADERS += \
    httprequest.h \
    panquickkernel.h \
    globalheader.h
