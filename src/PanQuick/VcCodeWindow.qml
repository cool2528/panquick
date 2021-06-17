import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
Window{
    id:vcCode
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    width:180
    height: 120
    property string jsondata: ""
    property var vcCodedata: {}
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
            x:0
            y:0
            width:parent.width
            height: 35
            color: Qt.lighter("#DCF0FF",1.05)
            Text{
                id:titleText
                text:"验证码"
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
                        vcCode.close()

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
                        vcCode.x += (mouseX-lastMouseX)
                        vcCode.y += (mouseY-lastMousey)
                    }
                }
            }
        }
        //正文内容
        //首先需要一个显示验证码的Image 然后需要一个输入验证码的 Edit 一个确认按钮
        Image{
            id:imageCode
            anchors.centerIn: parent
            source: ""
            width: 120
            height: 40
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var vcCodeInfo = baidu.getVcVode();
                    var vcCodeObj = JSON.parse(vcCodeInfo);
                    vcCode.vcCodedata = vcCodeObj;
                    imageCode.source = vcCode.vcCodedata.img
                    console.log(vcCodeInfo)
                }
            }
        }
        TextField{
            id:inputEdit
            anchors.top: imageCode.bottom
            anchors.topMargin: 10
            anchors.left: imageCode.left
            implicitWidth:60
            implicitHeight: 20
            text:""
            onTextChanged: {
                if(text.length === 4){
                    vcCode.close()
                    vcCode.vcCodedata.input = text
                    var vcstr = JSON.stringify(vcCode.vcCodedata)
                    baidu.getDownloadShareInfo(vcCode.jsondata,vcstr)
                }
            }
        }
        Button{
            id:btnYes
            anchors.left: inputEdit.right
            anchors.leftMargin: 10
            anchors.top: inputEdit.top
            text:"确定"
            style:ButtonStyle{
                background: Rectangle{
                    color:"#F4F8F9"
                    implicitWidth: 60
                    implicitHeight: 20
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
                vcCode.close()
                vcCode.vcCodedata.input = text
                var vcstr = JSON.stringify(vcCode.vcCodedata)
                baidu.getDownloadShareInfo(vcCode.jsondata,vcstr)
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
    function inputUriCode(jsondata,vccode){
        vcCode.jsondata = jsondata
        vcCode.vcCodedata = vccode
        imageCode.source = vcCode.vcCodedata.img
        vcCode.show()
    }
}
