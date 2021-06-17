import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
Window{
    id:fileSaveMoveDialog
    property string cookies: ""
    property string fileList: ""    //要操作的文件列表
    property var jsonObj: {}    //用户信息数据
    property bool windowType: true  //窗口是移动还是复制 true是移动 false是复制
    signal copymovesucceed(bool flags) // 用来确定移动/复制是否成功的 true代表成功 false 代表失败
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    height: 310
    width: 445
    /*内容布局*/
    Rectangle{
        id:contentFill
        anchors.fill: parent
        //color: "#DBF0FF"
        gradient:Gradient{
            GradientStop{
                position: 0.0
                color:"#DBF0FF"
            }
            GradientStop{
                position: 0.3
                color:Qt.lighter("#DBF0FF",1)
            }
            GradientStop{
                position: 1.0
                color:Qt.lighter("#DBF0FF",1.1)
            }
        }
        radius: 4
        //设置一个标题栏
        Rectangle{
            id:titleRect
            x:4
            y:0
            width:parent.width - 4
            height: 35
            color: Qt.lighter("#DBF0FF",1.05)
            Text{
                id:titleText
                text:"移动"
                x:10
                anchors.verticalCenter: parent.verticalCenter
            }
            //关闭按钮
            Rectangle{
                id:closeRect
                x:parent.width - 30
                y:0
                width: 30
                color: parent.color
                height:30
                Image{
                    id:closebtn
                    anchors.centerIn: parent
                    source: "images/close.png"
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        closeRect.color = "#FF5439"
                    }
                    onExited: {
                        closeRect.color = Qt.lighter("#DBF0FF",1.05)
                    }
                    onClicked: {
                        console.log("close")
                        fileSaveMoveDialog.close()
                    }
                }
            }
            MouseArea{
                height: parent.height
                property real lastMouseX: 0
                property real lastMousey: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 40
                onPressed: {
                    lastMouseX = mouseX
                    lastMousey = mouseY
                }
                onPositionChanged: {
                    if(pressed){
                        fileSaveMoveDialog.x += (mouseX-lastMouseX)
                        fileSaveMoveDialog.y += (mouseY-lastMousey)
                    }
                }
            }
            /*
            Rectangle{
                id:linebottom
                width:parent.width
                x:0
                y:30
                height: 1
                color:"#DCDCDC"
            }*/
        }
        Component{
            id:treeViewStyle
            TreeViewStyle{
                indentation:30
                branchDelegate:Image {
                    id: expand
                    //anchors.left: parent.left
                    //anchors.leftMargin: styleData.depth * 15
                    fillMode:Image.PreserveAspectFit
                    source: styleData.hasChildren ? (styleData.isExpanded ?"/images/collaps.png":"/images/expand.png"):""
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            console.log("11111")
                            if(!view.isExpanded(styleData.index)){
                                view.isExpand = true
                                treeViewModel.loderData(view.cookes,styleData.index);
                                view.expand(styleData.index)
                                view.isExpand = false
                            }else{
                                view.collapse(styleData.index)
                            }
                        }
                    }
                }
                itemDelegate:Rectangle{
                    color:styleData.selected ? "#C1E3FF" : "#E1F2FF"
                    width: parent.width
                    height: 30
                    Image{
                        id:imgIcon
                        anchors.verticalCenter: parent.verticalCenter
                        width:20
                        height: 15
                        fillMode:Image.PreserveAspectFit
                        source: styleData.isExpanded ? "/images/folder_exp.png":"/images/folder_coll.png"
                    }
                    Text{
                        anchors.left:imgIcon.right
                        anchors.leftMargin: 10
                        text:styleData.value
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                rowDelegate:Rectangle{
                    height: 30
                    color: "#E1F2FF"
                }
            }
        }
        /*正文内容*/
        TreeView {
            id: view
            property bool isExpand: false
            property string cookes:fileSaveMoveDialog.cookies
            headerVisible:false
            anchors.top: titleRect.top
            anchors.topMargin:35
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 230
            backgroundVisible:false
            model: treeViewModel
            BusyIndicator{
                id:busy
                running: view.isExpand
                anchors.centerIn: parent
                z:2
            }
            TableViewColumn {
                role: "name"
                resizable: true
            }
            style: treeViewStyle
            //获取当前选中的行的路径
            function getCurrentData(){
                var strResult = ""
                strResult = treeViewModel.getIndexData(view.currentIndex)
                console.log(strResult)
                return strResult
            }
            //移动文件

        }
        /*底部按钮*/
        Component{
            id:buttonYesStyle
            ButtonStyle{
                background: Rectangle{
                    implicitWidth: 80
                    implicitHeight: 30
                    radius: 8
                    border.color: "#96B9CF"
                    border.width: 1
                    color:control.hovered ? "#D9E7EF" :"#F4F8F9"
                }
                //文本
                label:Text{
                    text:control.text
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }


        Button{
            id:btnYes
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: view.bottom
            anchors.topMargin: 10
            text:qsTr("确定")
            tooltip: qsTr("确定")
            style:buttonYesStyle
            onClicked: {
                //确定按钮被单击
                var destPath = view.getCurrentData()
                console.log(destPath)
                var bResult = baidu.moveCopyFile(JSON.stringify(fileSaveMoveDialog.jsonObj),destPath,fileSaveMoveDialog.fileList,fileSaveMoveDialog.windowType)
                console.log(bResult)
                copymovesucceed(bResult)
                fileSaveMoveDialog.close()
            }
        }
        Button{
            id:btnNo
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: view.bottom
            anchors.topMargin: 10
            text:qsTr("取消")
            tooltip: qsTr("取消")
            style:buttonYesStyle
            onClicked: {
                //取消按钮被单击
                fileSaveMoveDialog.close()
            }
        }


    }
    BorderImage {
        anchors.fill: contentFill
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
    function moveCopy(file,jsondata,type){
        fileSaveMoveDialog.windowType = type
        if(!type){
            titleText.text = "复制到"
        }else{
            titleText.text = "移动到"
        }

        fileSaveMoveDialog.jsonObj = jsondata
        fileSaveMoveDialog.cookies = jsondata.cookies
        var x,jsonStr ="[";
        for(x in file){
            console.log(file[x])
            var strTem = '{"path":' + '"' + file[x] + '"}';
            jsonStr += strTem + ",";
        }
        var pos =  jsonStr.lastIndexOf(",")
        jsonStr = jsonStr.substr(0,pos)
        jsonStr += "]"
        console.log(jsonStr,pos)
        fileList = jsonStr;
        fileSaveMoveDialog.show()
    }
}
