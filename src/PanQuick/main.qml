import QtQuick 2.7
import QtQuick.Window 2.2
Window {
    id:initDlg
    visible: true
    width: 450
    height: 300
    title: qsTr("初始化")
    property int state: 0
    property bool error: false
    property bool isupdate: false   // 是否需要更新
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    Rectangle{
        id:mainRect
        anchors.fill: parent
        border.color: "#5fbbfd"
        border.width: 2
        radius: 4
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
        MouseArea{
            height: parent.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 50
            property real lastMouseX:0
            property real lastMouseY:0
            onPressed: {
                lastMouseX =mouseX
                lastMouseY =mouseY
            }
           onPositionChanged: {
             if(pressed){
                 initDlg.x += (mouseX-lastMouseX)
                 initDlg.y += (mouseY-lastMouseY)
             }
           }
        }
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
    //动画
    Timer{
        interval:500
        repeat:true
        running:true
        onTriggered: loopState()
    }
    Timer{
        id:initDetect
        interval: 2000
        onTriggered: initHandle.start()
    }

    Component.onCompleted: {
        console.log("init")
        initDetect.start()
    }
    Connections{
        target: detector
        onShow:{
            if("main"===show){
                initDlg.visible = true
            }else{
                initDlg.visible = false
            }
        }
        onUpdateStatus:{
            info.text = status
        }
        onIsupdate:{
            isupdate = flag //来自 C++ 方面的 检测是否 需要更新
        }
        onUpdateError:{
            error = errorflag   // 是否有错误出现
        }
    }
}
