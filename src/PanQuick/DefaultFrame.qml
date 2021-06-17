import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Item {
   property bool islogin: false
   property string facicon: "/images/user.svg"
   signal loginUser()
   signal parseurl(string url)
    Rectangle{
        id:rectDefault
        height: parent.height -50
        width:parent.width
        Component.onCompleted: {
            console.log("rectDefault高度："+rectDefault.height,"宽度："+rectDefault.width)
        }
        gradient: Gradient{
                             GradientStop{position: 0.0;color: globalobj.gradualcolorone;}
                             GradientStop{position: 0.3;color: globalobj.gradualcolortwo;}
                             GradientStop{position: 1.0;color: globalobj.gradualcolorthree;}
                         }
        Button{
            id:loginBtn
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 245
            implicitHeight: 65
            text:"登录网盘账号"
            style: ButtonStyle{
                background: Rectangle{
                    color:"#56CAFA"
                    radius: 50
                    implicitWidth: 245
                    implicitHeight: 65
                }
                label: Text{
                    verticalAlignment:Text.AlignVCenter
                    horizontalAlignment:Text.AlignHCenter
                    font.pixelSize: 18
                    font.bold: true
                    text:control.text
                    color:"#ffffff"
                }
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                property real cursor: cursorShape
                onEntered: {
                    cursor = cursorShape
                    if(containsMouse===true){
                        cursorShape = Qt.PointingHandCursor
                    }
                }
                onExited: {
                    cursorShape = cursor
                }
                onClicked: {
                    loginUser()
                    console.log("登陆按钮被单击")
                }
            }
        }
        TextField{
           id:inputUrlEdit
           anchors.top: loginBtn.bottom
           anchors.topMargin: 10
           horizontalAlignment:TextInput.AlignHCenter
           anchors.horizontalCenter: parent.horizontalCenter
           text:""
           font.pixelSize: 18
           placeholderText:"请输入分享链接或秒传链接"
           style:TextFieldStyle{
               background:Rectangle{
                   implicitWidth: 580
                   implicitHeight: 46
                   radius: 50
               }
               placeholderTextColor:"#C7B4C1"
           }
        }
        Button{
            id:parseBtn
            anchors.top: inputUrlEdit.top
            anchors.left: inputUrlEdit.right
            anchors.leftMargin: 5
            implicitHeight: 46
            implicitWidth: 100
            text:"打开"
            style: ButtonStyle{
                background: Rectangle{
                    color:"#56CAFA"
                    radius: 50
                    implicitWidth: 245
                    implicitHeight: 65
                }
                label: Text{
                    verticalAlignment:Text.AlignVCenter
                    horizontalAlignment:Text.AlignHCenter
                    font.pixelSize: 18
                    font.bold: true
                    text:control.text
                    color:"#ffffff"
                }
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                property real cursor: cursorShape
                onEntered: {
                    cursor = cursorShape
                    if(containsMouse===true){
                        cursorShape = Qt.PointingHandCursor
                    }
                }
                onExited: {
                    cursorShape = cursor
                }
                onClicked: {
                    var str = inputUrlEdit.text
                    inputUrlEdit.text = str.replace(new RegExp('\\s*','g'),"")
                    parseurl(inputUrlEdit.text)
                    console.log("解析按钮被单击")
                }
            }
        }
        //提示文本
        TextEdit{
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            font.pixelSize: 14
            color:"red"
            readOnly:true
            anchors.horizontalCenter: inputUrlEdit.horizontalCenter
           // anchors.verticalCenter: parent.verticalCenter
            text:"本软件完全免费，仅供学习交流使用.禁止倒卖。\r\n\r\n如果您是通过淘宝、拼多多等平台购买到本软件，请立即退货并差评！\r\n\r\n软件使用说明及常见问题请访问官网：http://panquick.com/"
        }
    }
}
