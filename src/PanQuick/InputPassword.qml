import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

Window{
    id:inputPassword
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    height: 100
    width: 460
    property string shareUrl: ""
    property string cookie: ""
    signal clicked(string result)
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
                text:"请输入提取码"
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
                        inputPassword.close()

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
                        inputPassword.x += (mouseX-lastMouseX)
                        inputPassword.y += (mouseY-lastMousey)
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
                    inputPassword.close()
                    var result = baidu.parseDownloadUrl(inputPassword.shareUrl,"",urlEdit.text,inputPassword.cookie)
                    inputPassword.clicked(result)
                }
            }
        }
    }
    //底部

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
    function inputPw(share,cookie){
        inputPassword.shareUrl = share
        inputPassword.cookie = cookie
        urlEdit.text = ""
        inputPassword.show()
    }
}
