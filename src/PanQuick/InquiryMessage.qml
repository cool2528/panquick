import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
//这个是询问是否退出账号的信息框
Window{
    id:inquiryMsg
    signal clicked(bool isYes)
    property alias msgContent: msgText.text
    property var fileList: []   //删除文件用的到
    property var userData: {}   //删除文件用的到
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    height: 155
    width: 260
    /*这里内容项开始*/
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
                text:"提示"
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
                        inquiryMsg.close()
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
                        inquiryMsg.x += (mouseX-lastMouseX)
                        inquiryMsg.y += (mouseY-lastMousey)
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
        //正文
       RowLayout{
           anchors.centerIn: parent
           spacing: 20
           Layout.fillWidth:true
           Image{
               id:inquiryIcon
               source: "/images/inquiry.png"
               fillMode: Image.PreserveAspectFit
           }
           Text{
               id:msgText
               text:"确定要退出账号吗？"
           }
       }
        //底部
       Button{
           id:btnYes
           anchors.left: parent.left
           anchors.leftMargin: 20
           anchors.bottom: parent.bottom
           anchors.bottomMargin: 10
           text:"是"
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
                inquiryMsg.close()
                inquiryMsg.clicked(true)
           }
       }
       //取消
        Button{
            id:btnNo
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text:"否"
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
            onClicked: {
                inquiryMsg.close()
                inquiryMsg.clicked(false)
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
   function deleteFile(fileList,UserData){
       inquiryMsg.fileList = fileList
       inquiryMsg.userData = UserData
       inquiryMsg.show()
   }
}
