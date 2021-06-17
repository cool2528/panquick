import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
Window{
    id:shareWindow
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    property var urlPathArr: []    //分享文件列表
    property var userInfo: {}   //保存用户登录成功信息
    signal shareResult(string szUrl)    //分享结果 成功传递分享的url 数据 失败是空字符串
    width: 430
    height: 280
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
            x:0
            y:0
            width:parent.width
            height: 35
            color: Qt.lighter("#DCF0FF",1.05)
            Text{
                id:titleText
                text:"分享文件"
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
                        shareWindow.close()

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
                        shareWindow.x += (mouseX-lastMouseX)
                        shareWindow.y += (mouseY-lastMousey)
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
        //单选框样式
        Component{
            id:radioButtonStyle
            RadioButtonStyle{
                indicator: Rectangle{
                    implicitHeight: 16
                    implicitWidth: 16
                    radius: 9
                    border.width: 1
                    border.color: control.activeFocus ? "darkblue" : "gray"
                    Rectangle{
                        anchors.fill: parent
                        visible: control.checked
                        color: Qt.lighter("#6DD881",1)
                        radius: 9
                        anchors.margins: 4
                    }
                }
                label: Text{
                    text:control.text
                }
            }
        }

        //正文内容
        ColumnLayout{
            id:shareLayout
            anchors.top: titleRect.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 100
            spacing: 20
            ExclusiveGroup{
                id:shareGroup
            }
            RowLayout{
                spacing: 20
                RadioButton{
                    text:"有提取码"
                    exclusiveGroup: shareGroup
                    style:radioButtonStyle
                    checked: true
                }
                Text{
                    text:"仅限拥有提取码者可查看"
                }
            }
            RowLayout{
                spacing: 20
                RadioButton{
                    text:"无提取码"
                    exclusiveGroup: shareGroup
                    style:radioButtonStyle
                }
                Text{
                    text:"无需提取码即可查看"
                }
            }
        }
        //分享形式
        Text{
            anchors.top: shareLayout.top
            anchors.left: parent.left
            anchors.leftMargin: 20
            text:"分享形式："
        }
        //有效期
        Text{
            id:validity
            anchors.top: shareLayout.bottom
            anchors.topMargin: 50
            anchors.left: parent.left
            anchors.leftMargin: 20
            text:"有效期："
        }
        RowLayout{
            anchors.top: validity.top
            anchors.left: shareLayout.left
            spacing: 20
            ExclusiveGroup{
                id:validityGroup
            }
            RadioButton{
                text:"永久有效"
                style: radioButtonStyle
                exclusiveGroup: validityGroup
                checked: true
            }
            RadioButton{
                text:"7天"
                style: radioButtonStyle
                exclusiveGroup: validityGroup
            }
            RadioButton{
                text:"1天"
                style: radioButtonStyle
                exclusiveGroup: validityGroup
            }
        }
        //按钮部分
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
        RowLayout{
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.left:parent.left
            anchors.leftMargin: parent.width - ((btnOk.width *2)+40)
            spacing: 20
            Button{
                id:btnOk
                text:"创建链接"
                style:buttonYesStyle
                onClicked: {
                    console.log(shareGroup.current.text)
                    var shareText = shareGroup.current.text
                    var validityText = validityGroup.current.text
                    var isEncrpty = true
                    var isTimeLimit = 0
                    var strPassWord = ""
                    var isSucceed = ""
                    if(shareText === "有提取码"){
                        isEncrpty = true
                    }else{
                        isEncrpty = false
                    }
                    if(validityText === "永久有效"){
                        isTimeLimit = 0
                    }else if(validityText === "7天"){
                        isTimeLimit = 7
                    }else{
                        isTimeLimit = 1
                    }
                    //分享文件/文件夹 调用c++ 执行
                    isSucceed = baidu.shareFile(JSON.stringify(shareWindow.userInfo),JSON.stringify(shareWindow.urlPathArr),isEncrpty,isTimeLimit)
                    shareWindow.shareResult(isSucceed)
                    shareWindow.close()
                }
            }
            Button{
                id:btnCancle
                text:"取消"
                style:buttonYesStyle
                onClicked: {
                    shareWindow.close()
                }
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
    //分享函数
    function shareFileFunc(fileList,UserData){
        shareWindow.userInfo = UserData
        shareWindow.urlPathArr = fileList
        shareWindow.show()
    }
    //取随机密码
    function getRandomPassWord(len){
        var rdmString = "";
        for (; rdmString.length < len; rdmString += Math.random().toString(36).substr(2));
        return rdmString.substr(0, len);
    }
}
