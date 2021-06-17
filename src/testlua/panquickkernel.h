#ifndef PANQUICKKERNEL_H
#define PANQUICKKERNEL_H
/*
@ 这个类主要执行lua脚本操作 目的就是
@ 为了远程更新一些 变动频繁的 http 请求
@ 目前我大致的 设计思路就是 给我一段脚本
@ 我替你执行 执行完以后 返回结果给你
*/
#include <QObject>
#include <QMap>
#include <string>
#include <memory>
class lua_State;
class HttpRequest;
enum ScriptType
{
    ParseDownload, //解析网盘内部下载地址
    ParseShareDownload, //解析用户分享文件
    ParseSearch, // 解析搜索脚本代码
    errorScript //未知的脚本类型
};
class exportHttp 
{
public:
	explicit exportHttp();
	//设置请求header key => value
	void setRequestHeader(const std::string key, const std::string value);
	//获取请求后得到的cookie
	std::string getCookie();
	//判断返回的协议头是否存在
	bool hasRawHeader(const std::string headerName);
	//返回远程协议头的value
	std::string rawHeader(const std::string headerName);
	//发送请求
	void send(int type, const std::string url, const std::string data = nullptr);
	//获取请求的body内容
	std::string getBodyContent();
	//获取本次请求http的状态码
	int getStatusCode();
	//开启/关闭HTTP重定向 默认是关闭的 true 开启 false 关闭
	void setRedirects(bool status);
	//设置http请求超时时间 默认60秒
	void setTimeOut(int nSec);
	//获取全部请求返回的协议头
	std::string getHeaders();
private:
	std::unique_ptr<HttpRequest> mHttpRequest;
};
class PanQuickKernel :public QObject
{
    Q_OBJECT
public:
    explicit PanQuickKernel(QObject* parent = nullptr);
    ~PanQuickKernel();
    /*
     * 加载并执行lua脚本代码
     * scriptPath 脚本代码文件路径
     * scriptType 脚本代码加载方式 1 表示文本方式加载 0表示文件方式加载
     * 返回值 true 表示执行脚本代码成功 false表示执行脚本代码失败
    */
    bool loadScript(const QString& scriptPath,const bool scriptType = true);
    /*
     * 获取当前加载脚本的类型 是下载还是搜索 还是解析
     *
    */
    ScriptType getScriptType();
    /*
     * 测试执行导出类函数
     *
    */
    void test();
private:
    lua_State* mL;  //lua的执行环境指针
    QMap<ScriptType,QString> mSwitch;
};

#endif // PANQUICKKERNEL_H
