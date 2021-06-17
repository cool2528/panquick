import QtQuick 2.7
import QtWebEngine 1.3
Item {
    property alias weburl: viewWeb.url
    property string cookie: ""
    property string facicon: "/images/baidu.svg"
    signal loginsuccess(string cookie)
    Rectangle{
        id:viewRect
        color:"transparent"
        implicitHeight: 394
        width:parent.width
        height: parent.height - 40
        WebEngineView{
            id:viewWeb
            anchors.fill: parent
            onLoadingChanged: {
                if(loadRequest.status === WebEngineView.LoadSucceededStatus){
                    var loginUrl = "pan.baidu.com/disk/home"
                    var url = loadRequest.url
                    console.log("------------sssaaaaaaaaa")
                    if(-1 !== String(url).indexOf(loginUrl)){
                        console.log(url)
                        cookie = cookiemangre.getcookie(url)
                        loginsuccess(cookie)
                    }
                }
            }
            onNewViewRequested: {
                console.log(request.userInitiated)
                request.openIn(viewWeb)
            }
        }
    }
    function clearHttpCache(){
        console.log("清除缓存 其他地方已经做了 这个函数 废弃")
    }
}
