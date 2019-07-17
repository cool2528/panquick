TEMPLATE = app

QT += qml quick network
CONFIG += c++11

SOURCES += main.cpp \
    initthread.cpp \
    detector.cpp

RESOURCES += qml.qrc \
    resource.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    initthread.h \
    detector.h
