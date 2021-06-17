import QtQuick 2.7

Rectangle{
    id:titleRect
    width: parent.width
    height: 50
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 4
    Rectangle{
        id:closeBtn
        x:410
        width:30
        height: 30
        MouseArea{
            anchors.fill: parent
            hoverEnabled:true
            onEntered:{
                closeImg.source = "/images/hover-close.png"
                console.log("hover")

            }
            onExited: {
                closeImg.source = "/images/button-close.png"
                console.log("exit")
            }
            onClicked: {
                Qt.quit()
            }
        }
        Image{
            id:closeImg
            x:11
            y:11
            z:1
            width: 19
            height: 19
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "/images/button-close.png"
        }
    }
}
