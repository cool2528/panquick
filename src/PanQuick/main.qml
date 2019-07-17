import QtQuick 2.5
import QtQuick.Window 2.2

Window {
    id:initDlg
    visible: true
    width: 450
    height: 300
    title: qsTr("初始化")
    property int state: 0
    property bool error: false
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    Rectangle{
        id:mainRect
        anchors.fill: parent
        border.color: "#5fbbfd"
        border.width: 2
        radius: 4
        MouseArea{
            anchors.fill: parent
            property real lastMouseX:0
            property real lastMouseY:0
            onPressed: {
                lastMouseX =mouseX
                lastMouseY =mouseY
            }
            onMouseXChanged: initDlg.x += (mouseX-lastMouseX)
            onMouseYChanged: initDlg.y += (mouseY-lastMouseY)
        }

        Image {
            id: logo
            x: 160
            y: 60
            width: 101
            height: 84
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            z: 1
            source: "/images/logo-start.png"
        }

        Text {
            id: info
            x: 174
            y: 202
            color: "#5fbbfd"
            text: qsTr("启动中...")
            anchors.horizontalCenterOffset: 0
            font.family: "Times New Roman"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 14
        }
    }
    Title{
        width:444
        anchors.horizontalCenter: parent.horizontalCenter
    }
    function loopState(){
        if(initDlg.error){
            logo.source = "images/logo-sad.png"
        }else{
            if(initDlg.state === 0){
                logo.source = "/images/logo-happy.png"
                initDlg.state = 1;
            }else{
                logo.source = "/images/logo-start.png"
                initDlg.state = 0;
            }
        }
    }

    Timer{
        interval:500
        repeat:true
        running:true
        onTriggered: loopState()
    }
}
