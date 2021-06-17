import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import an.utility 1.0   //托盘 c++实现
import "./js/navigation.js" as App
//这个是主界面
ApplicationWindow{
    id:panView
    visible: false
    width:800
    height: 600
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    property bool isLogig: false
    property int aria2Prot: 0   // aria2启动端口
    color: "transparent"
    //退出关闭提示
    CloseMessage{
        id:closeMsgBox
    }
    // 拦截窗口关闭事件
    onClosing:{
        close.accepted = false
        console.log("窗口关闭被拦截")
        closeMsgBox.show()
    }
    //密码输入框
    InputPassword{
        id:inputPass
        onClicked: {
            var fileinfo = JSON.parse(result)
            var title = ""
            if(fileinfo.list && fileinfo.title){
                title = fileinfo.title
                var multiTabItem = fileManger.item.tabMultiView
                if(multiTabItem){
                    multiTabItem.addTab(title,fileListManage)
                    multiTabItem.currentIndex = multiTabItem.count - 1
                    //把当前登录账号的基础信息插入到当前账号的userinfo中
                    var tabItem = multiTabItem.getTab(multiTabItem.currentIndex)
                    if(tabItem){
                        tabItem.item.initFileList(fileinfo)
                    }
                }
            }
        }
    }
    //失败信息提示框
    WarningToolTip{
        id:parseErrorMessage
    }
    //下载连接地址验证码输入框
    VcCodeWindow{
        id:codeimage
    }

    Rectangle{
        id:rectange
        height: panView.height
        width:  panView.width
        anchors.centerIn: parent
        color: "#FEFFFF"
        GlobalColor{
                 id:globalobj
        }
        //默认tab标签页面
        Component{
        id:defaultTab
        DefaultFrame{
            width:parent.width
            height: parent.height
            onLoginUser: {
                var tempTab = tabview.getTab(tabview.currentIndex)
                if(tempTab){
                    var multiTabItem = tempTab.item.tabMultiView
                    if(multiTabItem){
                        multiTabItem.removeTab(multiTabItem.currentIndex)
                        multiTabItem.addTab("账号登录",userLoginBrowser)
                        multiTabItem.currentIndex = multiTabItem.count - 1
                    }
                }
            }
            onParseurl: {
                var reg = new RegExp('^https?://pan\\.baidu\\.com','gi')
                if(url.search(reg) !== -1){
                    var result =  baidu.parseDownloadUrl(url,"","","")
                    var fileinfo = JSON.parse(result)
                    var title = ""
                    if(fileinfo.list && fileinfo.title){
                        title = fileinfo.title
                        var multiTabItem = fileManger.item.tabMultiView
                        if(multiTabItem){
                            multiTabItem.addTab(title,fileListManage)
                            multiTabItem.currentIndex = multiTabItem.count - 1
                            //把当前登录账号的基础信息插入到当前账号的userinfo中
                            var tabItem = multiTabItem.getTab(multiTabItem.currentIndex)
                            if(tabItem){
                                tabItem.item.initFileList(fileinfo)
                            }
                        }
                    }
                }else{
                    parseErrorMessage.show("逗比系列(ˉ▽ˉ；)...这是百度网盘链接?",5000)
                }
            }
        }
      }
        //账号登录浏览器
        Component{
            id:userLoginBrowser
            WebViewTemplate{
                id:webbrowseruser
                height: parent.height
                width:parent.width
                weburl: "https://pan.baidu.com"
                onLoginsuccess: {
                    console.log(cookie)
                    var multiTabItem = fileManger.item.tabMultiView
                    if(multiTabItem){
                        multiTabItem.removeTab(multiTabItem.currentIndex)
                        var userInfo = JSON.parse(baidu.getUserInfo(cookie))
                        if(userInfo.username !== undefined){
                            console.log(userInfo.bdstoken)
                            //添加登录账号table页面
                            multiTabItem.addTab(userInfo.username,downloadPage)
                            multiTabItem.currentIndex = multiTabItem.count - 1
                            //把当前登录账号的基础信息插入到当前账号的userinfo中
                            userInfo.cookie = cookie
                            var tabItem = multiTabItem.getTab(multiTabItem.currentIndex)
                            if(tabItem){
                                tabItem.item.userinfo = userInfo
                                //初始化网盘文件列表
                                tabItem.item.initListDir()
                                webbrowseruser.clearHttpCache()
                                cookiemangre.cleanCookie()
                            }
                        }
                    }
                }
            }
        }
          //标题
         QuickTitle{
             id:titleBar
             width: rectange.width
             anchors.top: parent.top
             anchors.left: parent.left
             height: 40
             MouseArea{
                 height: parent.height
                 property real lastMouseX: 0
                 property real lastMousey: 0
                 anchors.left: parent.left
                 anchors.right: parent.right
                 anchors.rightMargin: 200
                 onPressed: {
                     lastMouseX = mouseX
                     lastMousey = mouseY
                 }
                 onPositionChanged: {
                     if(pressed){
                         panView.x += (mouseX-lastMouseX)
                         panView.y += (mouseY-lastMousey)
                     }
                 }
             }
         }
         //文件列表 deleage
         Component{
             id:downloadPage
             CostomTableView{
                width:parent.width
                height:parent.height
             }
         }
         //下载分享文件列表
         Component{
             id:fileListManage
             FileListManage{
                width:parent.width
                height:parent.height
             }
         }

         //退出账号询问
         InquiryMessage{
             id:quitUserInquiry
             onClicked: {
                 if(isYes===true){
                     console.log(isYes)
                     var multiTabItem = fileManger.item.tabMultiView
                     if(multiTabItem){
                         multiTabItem.removeTab(multiTabItem.currentIndex)
                         cookiemangre.cleanCookie()
                         if(multiTabItem.count === 0){
                             multiTabItem.addTab("新建标签页",defaultTab)
                         }
                         //更新下导航信息
                         multiTabItem.selectTab(multiTabItem.currentIndex)
                     }
                 }
             }
         }
        CustomTabView{
             id:tabview
             x:0
             y:40
             height: panView.height - 40
             width:rectange.width
             Tab {
                 id:fileManger
                 height: tabview.height
                 width:tabview.width
                 title: "文件列表"
                 Item{
                    width: parent.width
                    height: parent.height
                    property alias tabMultiView: multiTab
                    property alias publicnavigation: navigation
                    PathNav{
                        id:navigation
                        width: parent.width
                        height: 40
                    }
                    MultiTabView{
                        //多标签管理
                        id:multiTab
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        width: parent.width
                        height: parent.height
                        Tab{
                            title:"新建标签页"
                            sourceComponent: defaultTab
                        }
                        //删除标签的时候
                        onDeleteTab:{
                            console.log(index)
                            var tabObj = multiTab.getTab(index).item
                            if(tabObj){
                                console.log(tabObj.userinfo)
                                if(tabObj.userinfo){
                                    //这里提醒是否退出账号
                                    quitUserInquiry.open()
                                }else{
                                    multiTab.removeTab(index)
                                    if(multiTab.count === 0){
                                        multiTab.addTab("新建标签页",defaultTab)
                                    }
                                    multiTab.selectTab(multiTab.currentIndex)
                                }
                            }
                        }
                        //标签被选中的时候
                        onSelectTab:{
                            console.log(index)
                            var tabObj = multiTab.getTab(index).item
                            if(tabObj){
                                console.log(tabObj.userinfo)
                                if(tabObj.userinfo){
                                    //更新 导航信息
                                    App.appNav.historyList = tabObj.pathCachdata
                                    App.appNav.historyIndex = tabObj.currentIndex
                                    console.log(tabObj.currentnavigation,typeof tabObj.currentnavigation)
                                    App.enterPath(tabObj.currentnavigation)
                                    tabObj.switchDir(tabObj.currentnavigation)
                                }else{
                                   //更新 导航信息
                                    App.appNav.historyList = []
                                    App.appNav.historyIndex = -1
                                    App.appNav.pathInfo = []
                                    App.appNav.path = "&"
                                }
                            }
                             multiTab.currentIndex = index
                        }
                    }
               }
               //Item 结束
             }
             //文件列表Tab---END
             Tab {
                 title: "正在下载"
             }
             Tab { title: "传输完成" }
             Tab { title: "更多功能" }
         }
    }
    //设置窗口背景阴影效果
    BorderImage {
            anchors.fill: rectange
            anchors.margins: -5
            border {
                left: 5
                top: 5
                right: 5
                bottom: 5
            }
            source: "images/shadow.png"
            smooth: true
   }
    Component.onCompleted: {
        console.log("init")
        cookiemangre.monitor()
    }
    //显示隐藏主窗口 来自c++ 的信号
    Connections{
        target: detector
        onShow:{
            if("quick"===show){
                panView.visible = true
                systemTray.visible = true
                panView.aria2Prot = detector.getPort()  //获取aria2启动的端口
                console.log(panView.aria2Prot)
            }else{
                panView.visible = false
                systemTray.visible = false
            }
        }
    }
    //来自百度解析接口的信号
    Connections{
        target: baidu
        onInputPassword:{
            console.log(shareUrl,cookie)
            inputPass.inputPw(shareUrl,cookie)
        }
        onShowMessage:{
            parseErrorMessage.show(message,5000)
        }
        onInputverCode:{
            //jsondata
            var vcCodeInfo = baidu.getVcVode();
            var vcCodeObj = JSON.parse(vcCodeInfo);
            if(vcCodeObj && !vcCodeObj.errno){
                if(vcCodeObj.img){
                    codeimage.inputUriCode(jsondata,vcCodeObj)
                }
            }else{
                parseErrorMessage.show("获取验证码失败",5000)
                console.log(vcCodeInfo)
            }

        }
    }

    //托盘程序 为了支持xp系统 使用 QT5.7 但是不支持qml中的托盘组件 故用c++ 实现
    SystemTaryIcon
    {
        id: systemTray
        menu: menu
        visible: false
        icon: "images/Tarylogo.ico"
        toolTip: "PanQuick 后台运行中..."
        onTrigger:
        {
            panView.requestActivate();
            panView.show();
        }

        TaryMenu
        {
            id: menu

            ActionItem
            {
                text: "打开主面板"
                onTriggered:{
                    console.log("显示主界面")
                    panView.requestActivate();
                    panView.show();
                }
            }
           SeparatorItem {}
            ActionItem
            {
                text: "设置中心"
            }
            SeparatorItem {}
            ActionItem
            {
                text: "退出程序"
                onTriggered: {
                    console.log("离开")
                    systemTray.onExit()
                }
            }
        }
    }
}
