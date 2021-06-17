#-------------------------------------------------
#
# Project created by QtCreator 2019-08-13T11:43:25
#
#-------------------------------------------------

QT       -= core gui
CONFIG(debug,debug|release){
message(1111)
TARGET = lua53d
}else{
TARGET = lua53
message(2222)
}

DESTDIR = ../../lib/
TEMPLATE = lib
CONFIG += staticlib
DESTDIR
unix {
    target.path = /usr/lib
    INSTALLS += target
}

HEADERS += \
    src/lapi.h \
    src/lauxlib.h \
    src/lcode.h \
    src/ldebug.h \
    src/ldo.h \
    src/lfunc.h \
    src/lgc.h \
    src/llex.h \
    src/llimits.h \
    src/lmem.h \
    src/lobject.h \
    src/lopcodes.h \
    src/lparser.h \
    src/lstate.h \
    src/lstring.h \
    src/ltable.h \
    src/ltm.h \
    src/lua.h \
    src/luaconf.h \
    src/lualib.h \
    src/lundump.h \
    src/lvm.h \
    src/lzio.h

SOURCES += \
    src/lapi.c \
    src/lauxlib.c \
    src/lbaselib.c \
    src/lcode.c \
    src/ldblib.c \
    src/ldebug.c \
    src/ldo.c \
    src/ldump.c \
    src/lfunc.c \
    src/lgc.c \
    src/linit.c \
    src/liolib.c \
    src/llex.c \
    src/lmathlib.c \
    src/lmem.c \
    src/loadlib.c \
    src/lobject.c \
    src/lopcodes.c \
    src/loslib.c \
    src/lparser.c \
    src/lstate.c \
    src/lstring.c \
    src/lstrlib.c \
    src/ltable.c \
    src/ltablib.c \
    src/ltm.c \
    src/lundump.c \
    src/lvm.c \
    src/lzio.c
