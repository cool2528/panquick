import QtQuick 2.7
import QtQuick.Layouts 1.0
//标题栏
Rectangle{
    id:titlebar
    implicitWidth: parent.width
    implicitHeight: 40
    color:"#DBF0FF"
    property bool isMax: false
    radius: 4
    Text{
        id:titleMsg
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text:"PanQuick - 永久免费，严禁倒卖"

    }
    //皮肤按钮
    Rectangle{
        x:parent.width - 201
        id:skinRect
        width: 40
        color: parent.color
        height:parent.height
        Image{
            id:skin
            anchors.centerIn: parent
            source: "images/skin.png"
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                skinRect.color = "#D4E4EF"
            }
            onExited: {
                skinRect.color = titlebar.color
            }
            onClicked: {
                console.log("sking")
            }
        }
    }
    //菜单按钮
    Rectangle{
        id:memuRect
        anchors.left: skinRect.right
        anchors.top: skinRect.top
        width: 40
        color: parent.color
        height:parent.height
        Image{
            id:menubtn
            anchors.centerIn: parent
            source: "images/menu.png"
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                memuRect.color = "#D4E4EF"
            }
            onExited: {
                memuRect.color = titlebar.color
            }
            onClicked: {
                console.log("setting")
            }
        }
    }
    //最小化按钮
    Rectangle{
        id:minRect
        anchors.left: memuRect.right
        anchors.top: memuRect.top
        width: 40
        color: parent.color
        height:parent.height
        Image{
            id:minbtn
            anchors.centerIn: parent
            source: "images/min.png"
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                minRect.color = "#D4E4EF"
            }
            onExited: {
                minRect.color = titlebar.color
            }
            onClicked: {
                console.log("min")
                panView.showMinimized();
            }
        }
    }
    //最大化按钮
    Rectangle{
        id:maxRect
        anchors.left: minRect.right
        anchors.top: minRect.top
        width: 40
        color: parent.color
        height:parent.height
        Image{
            id:maxbtn
            anchors.centerIn: parent
            source: "images/max.png"
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                maxRect.color = "#D4E4EF"
            }
            onExited: {
                maxRect.color = titlebar.color
            }
            onClicked: {
                console.log("max")
                if(!isMax){
                    panView.showMaximized()
                    isMax = true
                    maxbtn.source = "images/restore.png"
                }else{
                    panView.showNormal()
                    isMax = false
                    maxbtn.source = "images/max.png"
                }
            }
        }
    }
    //关闭按钮
    Rectangle{
        id:closeRect
        anchors.left: maxRect.right
        anchors.top: maxRect.top
        width: 40
        color: parent.color
        height:parent.height
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
                closeRect.color = titlebar.color
            }
            onClicked: {
                console.log("close")
                panView.close()
            }
        }
    }
}

