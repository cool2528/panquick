import QtQuick 2.7
import QtQuick.Controls 2.0
Item {
    id:coustonToolTip
    property real timeout: 1000
    property bool visibles: false
    property alias text: msgText.text
    property alias source: iconImage.source
    x:(parent.width - width) / 2
    Popup{
        id:toolPopup
        focus: true
        modal: false
        margins: 0
        padding: 0
        transformOrigin:Popup.Top
        implicitHeight: 30
        implicitWidth: Math.max(msgText.width + 10,130)
        closePolicy: Popup.NoAutoClose|Popup.CloseOnEscape
        background: Rectangle{
            anchors.fill: parent
            color: "#4C93FF"
            radius: 5
        }
        contentItem: Rectangle{
            anchors.fill: parent
            color:"#4C93FF"
            radius: 5
            Row{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                spacing:10
                Image{
                    id:iconImage
                    source: "/images/successd.png"
                }
                Text{
                    id:msgText
                    anchors.verticalCenter: parent.verticalCenter
                    text:""
                    color:"#FFFFFF"
                    horizontalAlignment:Text.AlignHCenter
                    verticalAlignment:Text.AlignVCenter
                }
            }
        }
    }
    Timer{
        id:timersss
        interval:coustonToolTip.timeout
        running:coustonToolTip.visibles
        repeat:coustonToolTip.visibles
        onTriggered:{
            toolPopup.close()
            coustonToolTip.visibles = false
        }
    }
    onVisiblesChanged: {
        if(visibles === true){
            toolPopup.open()
        }
    }
    function show(text,timeout){
        msgText.text = text
        if(timeout === undefined){
            timeout = -1
        }
        coustonToolTip.timeout = timeout
        coustonToolTip.visibles = true
    }
    function hide(){
        toolPopup.close()
         coustonToolTip.visibles = false
    }
}
