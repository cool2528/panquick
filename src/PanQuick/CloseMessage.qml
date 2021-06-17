import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
Window{
    id:closeMessageWindow
    height: 180
    width: 370
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
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
            color: Qt.lighter("#DCF0FF",1.05)
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
                        closeRect.color = Qt.lighter("#DCF0FF",1.05)
                    }
                    onClicked: {
                        console.log("close")
                        closeMessageWindow.close()

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
                        closeMessageWindow.x += (mouseX-lastMouseX)
                        closeMessageWindow.y += (mouseY-lastMousey)
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
       ColumnLayout{
        id:columnlay
        spacing:40
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
        ExclusiveGroup{id:group}
        RadioButton{
            id:hildTary
            text:"隐藏到托盘"
            checked: true
            height: 40
            exclusiveGroup:group
        }
        RadioButton{
            id:quitClose
            text:"立即退出程序"
            height: 40
            exclusiveGroup:group
        }
       }
        //底部
        Button{
            id:btnok
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
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
            onClicked: {
                closeMessageWindow.close()
                //panView.hide()
                 if(hildTary.checked){
                     panView.hide()
                 }else{
                     Qt.quit()
                 }
            }
        }
        CheckBox{
            id:isInquiry
            anchors.top: btnok.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text:"下次不再询问"
            implicitWidth: 15
            implicitHeight:15
            checked:false
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
                label:Text{
                       anchors.fill: parent
                       text:control.text
                    }
                spacing:5
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
}
