#ifndef BAIDUINTERFACE_H
#define BAIDUINTERFACE_H

#include <QObject>
#include "httprequest.h"
/*
@ 简单的封装下百度网盘相关操作的 api 接口
@ 获取用户的信息网盘内部操作等
*/
#define HOME_URL "https://pan.baidu.com/disk/home"  //网盘根目录
#define USER_AGENT "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
#define PATH_LIST_URL "https://pan.baidu.com/api/list?app_id=250528&bdstoken=%1&channel=chunlei&clienttype=0&desc=1&dir=%2&num=1000&order=time&page=1&showempty=0&web=1"
#define FILE_RENAME_URL "http://pan.baidu.com/api/filemanager?app_id=250528&async=1&bdstoken=%1&channel=chunlei&clienttype=0&opera=rename&web=1" //文件改名
#define FILE_DELETE_URL "https://pan.baidu.com/api/filemanager?opera=delete&async=1&channel=chunlei&web=1&app_id=250528&clienttype=0&bdstoken=%1" //文件删除
#define FILE_MOVE_URL "https://pan.baidu.com/api/filemanager?app_id=250528&async=1&bdstoken=%1&channel=chunlei&clienttype=0&opera=move&web=1"   //文件移动
#define FILE_COPY_URL "https://pan.baidu.com/api/filemanager?app_id=250528&async=1&bdstoken=%1&channel=chunlei&clienttype=0&opera=copy&web=1"   //文件复制
#define FILE_SHARE_URL "https://pan.baidu.com/share/set?app_id=250528&bdstoken=%1&channel=chunlei&clienttype=0&web=1" // 文件分享
#define FILE_SEND_PASSWORD_URL "https://pan.baidu.com/share/verify?channel=chunlei&clienttype=0&web=1&app_id=250528&surl=%1" //带密码访问提交
#define PATH_SHARE_LIST_INFO "https://pan.baidu.com/share/list?app_id=250528&channel=chunlei&clienttype=0&desc=1&num=100&order=time&page=1&root=1&shareid=%1&showempty=0&uk=%2&web=1" // 分享的文件信息
#define PATH_SHARE_LIST_PATH "https://pan.baidu.com/share/list?app_id=250528&channel=chunlei&clienttype=0&desc=1&num=100&order=time&page=1&shareid=%1&showempty=0&uk=%2&dir=%3&web=1" // 分享的文件信息
#define DOWNLOAD_FILE_INFO "https://pan.baidu.com/api/sharedownload?app_id=250528&channel=chunlei&clienttype=0&sign=%1&timestamp=%2&web=1" // 下载文件的解析
#define DOWNLOAD_VCCODE_URI "https://pan.baidu.com/api/getvcode?prod=pan&channel=chunlei&web=1&app_id=250528&clienttype=0&bdstoken=null" //验证码获取uri
class BaiduInterface : public HttpRequest
{
    Q_OBJECT
public:
    explicit BaiduInterface();
    /*
     * 根据给出的cookie 获取 当前cookie 的用户的基本信息
     * 如用户名 网盘大小等
    */
    Q_INVOKABLE QString getUserInfo(const QString& cookie);
    /*
     * 根据给出的cookie 获取当前cookie 用户的网盘文件列表
     * 成功返回 文件列表 json 字符串 失败返回空json字符串对象
     * jsondata 是通过 getUserInfo 返回的用户基本信息json字符串
     * path 是需要获取的指定目录下的文件路径 如根目录 / url编码后就是%2F
    */
    Q_INVOKABLE QString getFileList(const QString& jsondata,const QString& path);
    /*
     *  根据给出的用户登录成功后的用户信息 修改给定用户网盘内的文件名称
     * jsondata 是通过 getUserInfo 返回的用户基本信息json字符串
     * name 是需要获取的指定目录下的文件路径 如根目录 / url编码后就是%2F
     * newName 新的文件名
    */
    Q_INVOKABLE bool reNameFile(const QString& jsondata,const QString& name,const QString& newName);
    /*
     * 根据给出的用户登录成功后的用户信息 删除给定用户网盘内的文件/文件夹
     * jsondata是通过 getUserInfo 返回的用户基本信息json字符串
     * path 是需要删除的文件/文件夹路径
    */
    Q_INVOKABLE bool deleteFile(const QString& jsondata,const QString& path);
    /*
     *根据给出的用户登录成功后的用户信息 移动/复制给定用户网盘内的文件/文件夹
     *cookie 提供给 getUserInfo 返回的用户基本信息json字符串
     * destPath 是被移动到的路径 srcPath是被移动文件路径
     * type true是移动 false 是复制 默认是移动
    */
    Q_INVOKABLE bool moveCopyFile(const QString& jsondata,const QString& destPath,const QString& srcPath,bool type = true);
    /*
     * 根据用户给出的用户登录成功后的用户信息 分享给定用户网盘内的文件/文件夹
     * jsondata是通过 getUserInfo 返回的用户基本信息json字符串
     * fileList 是需要分享文件ID数组 isEncrypt 表示是否有访问码 timeLimit表示分享文件的有效期
    */
    Q_INVOKABLE QString shareFile(const QString& jsondata,const QString& fileList,bool isEncrypt,quint32 timeLimit);
    /*
     * 解析用户分享的文件真实地址
     * shareUrl 是外部分享的url文件地址
     * seCode 验证码
     * password 访问密码
     * cookie 当需要密码或者验证码时可能上次已经请求一遍了携带的cookie这个时候可以使用上了
    */
    Q_INVOKABLE QString parseDownloadUrl(const QString& shareUrl,const QString& seCode,const QString& password,const QString& cookie);
    /*
     * 获取分享下载带目录的文件列表信息
     * cookie 内容
     * path 需要获取的路径
    */
    Q_INVOKABLE QString getShareFilePath(const QString& cookie,const QString& path,const QString& shareid,const QString& uk);
    /*
     * 根据给出的分享链接的 fs_id , shareID,uk sign 等信息解析出真实的下载地址信息
     * jsonData 包含需要下载的文件需要提供的信息 如 cookie  fs_id , shareID,uk sign 等
     * verificationCode 输入频繁时需要提供的验证码
    */
    Q_INVOKABLE QString getDownloadShareInfo(const QString& jsonData,const QString& verificationCode);
    /*
     * 获取验证码
    */
    Q_INVOKABLE QString getVcVode();
signals:
    //输入密码
    void inputPassword(QString shareUrl,QString cookie);
    //错误信息提示
    void showMessage(QString message);
    //输入验证码
    void inputverCode(QString jsondata);
public slots:

private:
    QString getShareFileInfo(const QString& cookie,const QString& jsonData);
    QString formatFileSize(uint64_t size);
    bool checkFileExist(const QString& filePath);
    QString urlCoding(const QString& data);
    QString getCookieValue(const QString& cookie,const QString& key);
    QString random(int len = 4);
};

#endif // BAIDUINTERFACE_H
