import QtQuick 2.7
import QtQuick.Controls 2.0
Item {
    id:root
    width: parent.width
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
    property alias source: imageshow.source
    property alias tootipText: toolTipMsg.text
    property url normalUrl:""      //常规状态下的图片路径
    property url hoveredUrl:""     //悬浮
    property url pressedUrl:""     //按下
    property url disabledUrl:""    //禁用
    signal clicked()
    Rectangle{
        height: parent.height
        width: parent.height
        color: "#00000000"
        Image {
            id: imageshow
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            source: ""
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            property real cursor: cursorShape
            onEntered: {
                cursor = cursorShape
                if(containsMouse === true){
                    cursorShape = Qt.PointingHandCursor
                    toolTipMsg.visible = true
                    if (hoveredUrl.toString() !=="" && normalUrl.toString() !==""){
                        console.log(hoveredUrl.toString())
                        imageshow.source = hoveredUrl
                    }
                }
            }
            onExited: {
                cursorShape = cursor
                toolTipMsg.visible = false
                if (hoveredUrl.toString() !=="" && normalUrl.toString() !==""){
                    console.log(hoveredUrl)
                    imageshow.source = normalUrl
                }
            }
            onClicked: root.clicked()
        }
        ToolTip{
            id:toolTipMsg
            text:""
            timeout:1500
        }
    }
}
