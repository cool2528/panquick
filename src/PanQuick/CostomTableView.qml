import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./js/navigation.js" as Navigation
Item{
    id:tableRoot
    property alias model: tableViewtest.model
    property var userinfo: {}   //用户信息
    property var pathCachdata: []   //缓存当前导航的 历史纪录 都打开过什么目录
    property bool loadStatus: true //是否处于加载状态
    property var currentnavigation: "/"  //当前导航路径
    property int currentIndex: -1   //当前历史导航索引

    BusyIndicator{
        id:busy
        running: tableRoot.loadStatus
        anchors.centerIn: parent
        z:2
    }
    //重命名对话框
    RenameBox{
        id:renameDlg
    }
    //删除文件信息框
    InquiryMessage{
        id:delFileMsg
        msgContent:"确定要删除所选文件吗？"
        onClicked: {
            if(isYes){
                var userData = JSON.stringify(delFileMsg.userData)
                var tmpPath = ""
                for(var k = 0; k < delFileMsg.fileList.length; ++k){
                    var tmpObj = delFileMsg.fileList[k]
                    if(tmpObj){
                        var path = tmpObj.path
                        baidu.deleteFile(userData,path)
                        tmpPath = path
                    }
                }
                //刷新目录
                tableRoot.switchDir(tableRoot.getSuperPath(tmpPath))
                succeedMsgTooltip.show("删除成功",5000)
            }
        }
    }
    //移动文件
    FileSaveDialog{
        id:moveDlg
        onCopymovesucceed: {
            if(flags){
                if(moveDlg.windowType){
                    succeedMsgTooltip.show("移动成功",5000)
                }else{
                    succeedMsgTooltip.show("复制成功",5000)
                }
            }else{
                if(moveDlg.windowType){
                    warningMsgTooltip.show("移动文件失败，部分文件已经存在目标文件夹中",5000)
                }else{
                    warningMsgTooltip.show("复制文件失败，部分文件已经存在目标文件夹中",5000)
                }
            }
        }
    }

    //成功信息提示框
    SucceedToolTip{
        id:succeedMsgTooltip
    }
    //失败信息提示框
    WarningToolTip{
        id:warningMsgTooltip
    }
    //分享成功复制窗口
    ShareCopyUrlWindow{
        id:shareUrlWindow

    }

    //分享对话框
    ShareDialog{
        id:shareDialog
        onShareResult: {
            if(szUrl === ""){
                warningMsgTooltip.show("分享文件资源失败，或许资源被和谐了请稍后再试",5000)
            }else{
                if(szUrl.indexOf("pan.baidu.com")!=-1){
                    shareUrlWindow.setUrlText(szUrl)
                }else{
                    warningMsgTooltip.show("分享文件资源失败，0x00000005错误",5000)
                }
            }
        }
    }

    TableView{
        id:tableViewtest
        width:parent.width
        height: parent.height - 42
        property real localX: 0
        property real localY: 0
        property bool allcheck: false
        horizontalScrollBarPolicy:Qt.ScrollBarAsNeeded
        TableViewColumn{
            role:"check"
            title:""
            width:25
            movable:false
            resizable:false
        }
        TableViewColumn{
            role:"type"
            title:""
            width:32
            movable:false
            resizable:false
        }
        TableViewColumn{
            role:"name"
            title:"文件名"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount * 2
        }
        TableViewColumn{
            role:"size"
            title:"大小"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount /1.5
        }
        TableViewColumn{
            role:"timer"
            title:"修改时间"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount /1.0
        }
        alternatingRowColors:false
        model:ListModel{

        }
        style:TableViewStyle{
            backgroundColor:"#D7EFFF"
            headerDelegate:  Rectangle{
                implicitWidth: 200
                implicitHeight: 30
                color:"#D7EFFF"
                border.color: "#D2E7F5"
                border.width: 1
                //visible: styleData.column!==0 ? true :false
                CheckBox{
                    anchors.left: parent.left
                    anchors.margins: 5
                    text:""
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 15
                    implicitHeight:15
                    visible: !styleData.column
                    checked:tableViewtest.allcheck
                    style:CheckBoxStyle{
                        indicator:Rectangle{
                            implicitHeight: 15
                            implicitWidth: 15
                            border.color: control.activeFocus  ? "#06A8FF":"#B3B3B3"
                            border.width: 2
                            Image {
                                visible: control.checked
                                source: "images/selected.png"

                            }
                        }
                    }
                }
                Text{
                    visible: styleData.column!==0 ? true :false
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text:styleData.value
                }
            }
            itemDelegate:Rectangle{
                id:rowitem
                implicitWidth: 200
                implicitHeight: 20
                color:styleData.selected ? "#C7E6FF": "#D7EFFF"
                CheckBox{
                    id:checkbox
                    anchors.left: parent.left
                    anchors.margins: 5
                    text:""
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 15
                    implicitHeight:15
                    visible: !styleData.column
                    checked:styleData.value
                    style:CheckBoxStyle{
                        indicator:Rectangle{
                            implicitHeight: 15
                            implicitWidth: 15
                            border.color: control.activeFocus  ? "#06A8FF":"#B3B3B3"
                            border.width: 2
                            Image {
                                visible: control.checked
                                source: "images/selected.png"

                            }
                        }
                    }
                }
                Image{
                    id:iconimage
                    anchors.left:checkbox.right
                    anchors.leftMargin: -20
                    visible: styleData.column === 1 ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    source: styleData.column ===1 && styleData.value!=="" ? "images/" + styleData.value + ".png" :""
                }
                Text{
                    visible: styleData.column > 1 ? true : false
                    anchors.left:iconimage.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text:styleData.value
                }
            }
            rowDelegate:Rectangle{
                color:"#D7EFFF"
                height: 30
            }
        }
        //右键菜单
        MouseArea{
            anchors.left: parent.left
            anchors.leftMargin: 20
            height: parent.height
            anchors.right: parent.right
            acceptedButtons:Qt.RightButton
            onClicked: {
                if(mouse.button === Qt.RightButton){
                    tableViewtest.localX = mouseX
                   tableViewtest.localY = mouseY
                   console.log(mouseX,mouseY)
                    var row = tableViewtest.rowAt(tableViewtest.localX,tableViewtest.localY)
                    if(row >=0){
                        tableViewtest.clicked(row)
                        var isdir = tableViewtest.model.get(row).isdir
                        var thumbs = tableViewtest.model.get(row).thumbs
                        console.log("thumbs===",thumbs)
                        if(isdir){
                            option_dir_menu.popup()
                        }else if(thumbs===6){
                            option_video_menu.popup()
                        }else{
                             option_menu.popup()
                        }
                   }else{
                        option_empty_menu.popup()
                    }

                   mouse.accepted = true

                }
            }

            //菜单针对一般文件的
            ListMenu{
                id:option_menu
                MenuItem{
                    text:"下载"
                    onTriggered: {
                        console.log("下载")
                    }
                }
                MenuItem{
                    text:"打包下载"
                    onTriggered: {
                        console.log("打包下载")
                    }
                }
                MenuItem{
                    text:"分享下载"
                    onTriggered: {
                        console.log("分享下载")
                    }
                }
                MenuItem{
                    text:"提取链接"
                    onTriggered: {
                        console.log("提取链接")
                    }
                }
                MenuItem{
                    text:"分享"
                    onTriggered: {
                        console.log("分享")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.fs_id)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                         shareDialog.shareFileFunc(listFile,jsonData)
                    }
                }
                MenuItem{
                    text:"创建秒传链接"
                    onTriggered: {
                        console.log("创建秒传链接")
                    }
                }
                MenuItem{
                    text:"复制到"
                    onTriggered: {
                        console.log("复制到")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,false)
                    }
                }
                MenuItem{
                    text:"移动到"
                    onTriggered: {
                        console.log("移动到")
                        //moveDlg.show()
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,true)
                    }
                }
                MenuItem{
                    text:"重命名"
                    onTriggered: {
                        console.log("重命名")
                        console.log(tableViewtest.currentRow)
                        var path = tableViewtest.model.get(tableViewtest.currentRow).path
                        var jsonData = JSON.stringify(tableRoot.userinfo)
                        renameDlg.rename(path,jsonData)
                    }
                }
                MenuItem{
                    text:"删除"
                    onTriggered: {
                        console.log("删除")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj)
                            }
                        }
                        delFileMsg.deleteFile(listFile,tableRoot.userinfo)
                    }
                }
                MenuItem{
                    text:"属性"
                    onTriggered: {
                        console.log("属性")
                    }
                }
            }
            //菜单针对是文件夹的
            ListMenu{
                id:option_dir_menu
                MenuItem{
                    text:"下载"
                    onTriggered: {
                        console.log("下载")
                    }
                }
                MenuItem{
                    text:"打开"
                    onTriggered: {
                        console.log("打开文件夹")
                    }
                }
                MenuItem{
                    text:"打包下载"
                    onTriggered: {
                        console.log("打包下载")
                    }
                }
                MenuItem{
                    text:"分享下载"
                    onTriggered: {
                        console.log("分享下载")
                    }
                }
                MenuItem{
                    text:"提取链接"
                    onTriggered: {
                        console.log("提取链接")
                    }
                }
                MenuItem{
                    text:"分享"
                    onTriggered: {
                        console.log("分享")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.fs_id)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                         shareDialog.shareFileFunc(listFile,jsonData)
                    }
                }
                MenuItem{
                    text:"创建秒传链接"
                    onTriggered: {
                        console.log("创建秒传链接")
                    }
                }
                MenuItem{
                    text:"复制到"
                    onTriggered: {
                        console.log("复制到")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,false)
                    }
                }
                MenuItem{
                    text:"移动到"
                    onTriggered: {
                        console.log("移动到")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,true)
                    }
                }
                MenuItem{
                    text:"重命名"
                    onTriggered: {
                        console.log("重命名")
                        console.log(tableViewtest.currentRow)
                        var path = tableViewtest.model.get(tableViewtest.currentRow).path
                        var jsonData = JSON.stringify(tableRoot.userinfo)
                        renameDlg.rename(path,jsonData)
                    }
                }
                MenuItem{
                    text:"删除"
                    onTriggered: {
                        console.log("删除")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj)
                            }
                        }
                        delFileMsg.deleteFile(listFile,tableRoot.userinfo)
                    }
                }
                MenuItem{
                    text:"属性"
                    onTriggered: {
                        console.log("属性")
                    }
                }
            }
            //菜单针对是视频文件的
            ListMenu{
                id:option_video_menu
                MenuItem{
                    text:"下载"
                    onTriggered: {
                        console.log("下载")
                    }
                }
                MenuItem{
                    text:"播放"
                    onTriggered: {
                        console.log("播放视频")
                    }
                }
                MenuItem{
                    text:"打包下载"
                    onTriggered: {
                        console.log("打包下载")
                    }
                }
                MenuItem{
                    text:"分享下载"
                    onTriggered: {
                        console.log("分享下载")
                    }
                }
                MenuItem{
                    text:"提取链接"
                    onTriggered: {
                        console.log("提取链接")
                    }
                }
                MenuItem{
                    text:"分享"
                    onTriggered: {
                        console.log("分享")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.fs_id)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        shareDialog.shareFileFunc(listFile,jsonData)
                    }
                }
                MenuItem{
                    text:"创建秒传链接"
                    onTriggered: {
                        console.log("创建秒传链接")
                    }
                }
                MenuItem{
                    text:"复制到"
                    onTriggered: {
                        console.log("复制到")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,false)
                    }
                }
                MenuItem{
                    text:"移动到"
                    onTriggered: {
                        console.log("移动到")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.path)
                            }
                        }
                        var jsonData = tableRoot.userinfo
                        moveDlg.moveCopy(listFile,jsonData,true)
                    }
                }
                MenuItem{
                    text:"重命名"
                    onTriggered: {
                        console.log("重命名")
                        console.log(tableViewtest.currentRow)
                        var path = tableViewtest.model.get(tableViewtest.currentRow).path
                        var jsonData = JSON.stringify(tableRoot.userinfo)
                        renameDlg.rename(path,jsonData)
                    }
                }
                MenuItem{
                    text:"删除"
                    onTriggered: {
                        console.log("删除")
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj)
                            }
                        }
                        delFileMsg.deleteFile(listFile,tableRoot.userinfo)
                    }
                }
                MenuItem{
                    text:"属性"
                    onTriggered: {
                        console.log("属性")
                    }
                }
            }
            //菜单当未选中任何文件的时候
            ListMenu{
                id:option_empty_menu
                MenuItem{
                    text:"刷新"
                    onTriggered: {
                        console.log("刷新")
                    }
                }
                MenuItem{
                    text:"新建文件夹"
                    onTriggered: {
                        console.log("新建文件夹")
                    }
                }
            }
        }
        //左键单击选中
        MouseArea{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: tableViewtest.width - 20
            height: parent.height
            hoverEnabled:true
            acceptedButtons: Qt.LeftButton
            onClicked: {
                console.log("-------------")
                tableViewtest.localX = mouseX
               tableViewtest.localY = mouseY
               console.log(mouseX,mouseY)
                var row = tableViewtest.rowAt(tableViewtest.localX,tableViewtest.localY)
                if(row >=0){
                    tableViewtest.clicked(row)
               }
               if(tableViewtest.localY < 30){
                   tableViewtest.allcheck = ! tableViewtest.allcheck
                   console.log(tableViewtest.localY)
                   for(var i = 0;i < tableViewtest.model.count;i++){
                       tableViewtest.model.setProperty(i,"check",tableViewtest.allcheck)
                   }
               }

               mouse.accepted = true
            }
        }
        //table单击事件
        onClicked:{
            tableViewtest.currentRow = row
            var isCheck = tableViewtest.model.get(row).check
            tableViewtest.model.setProperty(row,"check",!isCheck)
            if(!isCheck){
                tableViewtest.selection.select(row)
            }else{
                tableViewtest.selection.deselect(row)
            }
        }
        //双击事件
        onDoubleClicked:{
            var isDir = tableViewtest.model.get(row).isdir
            if(isDir){
                var path = tableViewtest.model.get(row).path
                var name = tableViewtest.model.get(row).name
               // tableRoot.switchDir(path)
                var pathItem = {name:name,path:path}
                tableRoot.pathCachdata.push(pathItem)
                tableRoot.currentnavigation = path
                Navigation.enterPath(path)
            }
        }
        Component.onCompleted: {
            console.log("width "+tableRoot.width,"height  "+tableRoot.height)
        }
    }

    //初始化网盘文件目录列表
    function initListDir(){
        console.log("------onCompleted-初始化的时候去读取网盘文件列表-----")
        Navigation.appNav.historyList = tableRoot.pathCachdata
        Navigation.enterPath(currentnavigation)
        switchDir("/")
    }
    // 切换目录
    function switchDir(path){
        tableRoot.loadStatus = true
        tableViewtest.model.clear()
        if(tableRoot.userinfo.cookie!==undefined){
            var paths = encodeURIComponent(path)
            var jsonData = JSON.stringify(tableRoot.userinfo)
            jsonData = baidu.getFileList(jsonData,paths)
            var jsonObj = JSON.parse(jsonData)
            if(jsonObj){
                if(jsonObj.list){
                    for (var x in jsonObj.list){
                        tableViewtest.model.append(jsonObj.list[x])
                       // console.log(JSON.stringify(jsonObj.list[x]))
                    }
                }
            }
            tableRoot.currentIndex = Navigation.appNav.historyIndex
        }
        tableRoot.loadStatus = false
    }
    //返回路径
    function getSuperPath(path){
        var pos = path.lastIndexOf("/")
        var result = "/"
        if(pos !==-1){
           result = path.substr(0,pos + 1)
        }
        return result
    }
}

