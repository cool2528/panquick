#include "panquickkernel.h"
#include "httprequest.h"
#include "globalheader.h"
#include <QDebug>
#include <tuple>
#include <QFile>
#include <QFileInfo>
#include <QByteArray>
extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include "LuaIntf/LuaIntf.h"
using namespace LuaIntf;
namespace LuaIntf
{

namespace LuaBind {
    void Bind(lua_State* L){
        assert(L);
		LuaIntf::LuaBinding(L).beginClass<exportHttp>("http")
			.addConstructor(LUA_ARGS())
			.addFunction("setHeader", &exportHttp::setRequestHeader)
			.addFunction("getCookie", &exportHttp::getCookie)
			.addFunction("hasRawHeader", &exportHttp::hasRawHeader)
			.addFunction("rawHeader", &exportHttp::rawHeader)
			.addFunction("send", &exportHttp::send)
			.addFunction("getStatusCode", &exportHttp::getStatusCode)
			.addFunction("setRedirects", &exportHttp::setRedirects)
			.addFunction("setTimeOut", &exportHttp::setTimeOut)
			.addFunction("getHeaders", &exportHttp::getHeaders)
			.addFunction("getBodyContent",&exportHttp::getBodyContent)
			.endClass();
    }
}}
PanQuickKernel::PanQuickKernel(QObject *parent):QObject(parent)
{
    //构造函数 第一步 就是 初始化 lua执行环境
    mSwitch[ParseDownload] = "onDownload";
    mSwitch[ParseShareDownload] = "onSharedownload";
    mSwitch[ParseSearch] = "onSearch";
    mSwitch[errorScript] = "error";
    mL = luaL_newstate();	//初始化lua酷
    assert(mL);
    luaL_openlibs(mL);			//打开所有lua支持的库
	LuaBind::Bind(mL);
}

PanQuickKernel::~PanQuickKernel()
{
    if(mL){
        lua_close(mL);		//关闭lua
        mL = nullptr;
    }
}

bool PanQuickKernel::loadScript(const QString& scriptPath,const bool scriptType)
{
    bool bResult = false;
    if(scriptPath.isEmpty()){
        return bResult;
    }
    if(!scriptType){
        QFileInfo info(scriptPath);
        if(info.exists()){
            QFile in(scriptPath);
			if (!in.open(QIODevice::ReadOnly | QIODevice::Text)) {
				return bResult;
			}
			QTextStream file(&in);
			auto fileData = file.readAll();
			std::string data = fileData.toStdString();
            int status = luaL_dostring(mL,data.c_str());
            if(!status){
                bResult = true;
            }
			in.close();
        }
    }else{
		int status = luaL_dofile(mL, scriptPath.toStdString().c_str());
        if(status){
            bResult = true;
        }
    }
    return bResult;
}

ScriptType PanQuickKernel::getScriptType()
{
    ScriptType typeResult = errorScript;
    lua_getglobal(mL,"script_info");
    if(lua_istable(mL,-1)){
        lua_pop(mL,1);
        lua_getglobal(mL,"onDownload");
        if(lua_isfunction(mL,-1)){
            typeResult = ParseDownload; //表示是执行下载的lua脚本
        }
        lua_pop(mL,1);
        lua_getglobal(mL,"onSearch");
        if(lua_isfunction(mL,-1)){
            typeResult = ParseSearch; //表示是执行搜索的lua脚本
        }
        lua_pop(mL,1);
        lua_getglobal(mL,"onSharedownload");
        if(lua_isfunction(mL,-1)){
            typeResult = ParseShareDownload; //表示是分享下载的lua脚本
        }
        lua_pop(mL,1);
    }
    return typeResult;
}

void PanQuickKernel::test()
{
	LuaRef task(mL, "test");
	exportHttp taskarg;

	task(&taskarg);
}

exportHttp::exportHttp()
{
	mHttpRequest = std::make_unique<HttpRequest>();
}

void exportHttp::setRequestHeader(const std::string key, const std::string value)
{
	mHttpRequest->setRequestHeader(key.c_str(), value.c_str());
}

std::string exportHttp::getCookie()
{
	QString result =  mHttpRequest->getCookie();
	return result.toStdString();
}

bool exportHttp::hasRawHeader(const std::string headerName)
{
	return mHttpRequest->hasRawHeader(headerName.c_str());
}

std::string exportHttp::rawHeader(const std::string headerName)
{
	return mHttpRequest->rawHeader(headerName.c_str()).toStdString();
}

void exportHttp::send(int type, const std::string url, const std::string data /*= nullptr*/)
{
	mHttpRequest->send(RequestType(type), url.c_str(), data.c_str());
}

std::string exportHttp::getBodyContent()
{
	return mHttpRequest->getBodyContent().data();
}

int exportHttp::getStatusCode()
{
	return mHttpRequest->getStatusCode();
}

void exportHttp::setRedirects(bool status)
{
	mHttpRequest->setRedirects(status);
}

void exportHttp::setTimeOut(int nSec)
{
	mHttpRequest->setTimeOut(nSec);
}

std::string exportHttp::getHeaders()
{
	return mHttpRequest->getHeaders().toStdString();
}
