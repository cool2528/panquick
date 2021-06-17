import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
Popup{
    id:renameBox
    modal: false
    focus: true
    x:(parent.width- width)/2
    y:(parent.height - height) /2
    margins:0
    padding:0
    closePolicy: Popup.NoAutoClose|Popup.CloseOnEscape
    property string path: ""
    property string userData: ""
    implicitHeight: 100
    implicitWidth: 460
    background:Rectangle{
        id:backgroundRect
        anchors.fill: parent
        color: "#DBF0FF"
        radius: 4
    }
    /*这里内容项开始*/
    Rectangle{
        id:contentFill
        anchors.fill: parent
        color: "#DBF0FF"
        radius: 4
        //设置一个标题栏
        Rectangle{
            id:titleRect
            x:4
            y:0
            width:parent.width - 4
            height: 35
            color: "#DCF0FF"
            Text{
                id:titleText
                text:"重命名"
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
                        closeRect.color = "#DBF0FF"
                    }
                    onClicked: {
                        console.log("close")
                        renameBox.close()

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
                        renameBox.x += (mouseX-lastMouseX)
                        renameBox.y += (mouseY-lastMousey)
                    }
                }
            }
            Rectangle{
                id:linebottom
                width:parent.width
                x:0
                y:30
                height: 1
                color:"#DCDCDC"
            }
        }
        //正文
       RowLayout{
        id:rowlay
        spacing:20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        TextField{
            id:urlEdit
            text:""
            implicitHeight:35
            implicitWidth: 300
            anchors.left: parent.left
            anchors.leftMargin: 10
        }
        Button{
            id:btnYes
            text:"确定"
            style:ButtonStyle{
                background: Rectangle{
                    color:"#F4F8F9"
                    implicitWidth: 80
                    implicitHeight: 30
                    radius: 8
                    border.color: "#96B9CF"
                    border.width: 1
                }
                label:Text{
                    text:control.text
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment:Text.AlignVCenter
                }
            }
            onClicked:{
                 renameBox.close()
                if(baidu.reNameFile(renameBox.userData,renameBox.path,urlEdit.text)===true){
                    msgTooltip.show("重命名成功",5000)
                }

                //刷新当前路径
                tableRoot.switchDir(tableRoot.getSuperPath(renameBox.path))
            }
        }
       }
        //底部

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
   function rename(path,userData){
       renameBox.path = path
       renameBox.userData = userData
       renameBox.open()
   }
}
