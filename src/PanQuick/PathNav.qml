import QtQuick 2.7
import QtQuick.Controls 1.4
import "./js/navigation.js" as Navigation
Item{
    id:pathNavRoot
    width:parent.width
    height: parent.height
    Row{
        id:btnhome
        spacing: 10
        width: (parent.height * 0.6 + spacing) * 4
        height: parent.height
        CostomButton{
            property bool canReturn: Navigation.appNav.historyIndex > 0
            height: parent.height * 0.6
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: canReturn ? 'images/file_back_normal.png' : 'images/file_back_disabled.png'
            tootipText:"后退"
            onClicked: {
                if (canReturn){
                    console.log("后退")
                    Navigation.retreat()
                }
            }
        }
        CostomButton {
            //前进
            property bool canEnter: Navigation.appNav.historyIndex < Navigation.appNav.historyList.length - 1
            height: parent.height * 0.6
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: canEnter ? 'images/file_forward_normal.png' : 'images/file_forward_disabled.png'
            tootipText:"前进"
            onClicked: {
                if (canEnter) {
                    console.log("前进")
                    Navigation.goForward()
                }
            }
        }
        CostomButton {
            height: parent.height * 0.6
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: 'images/file_home_normal.png'
            tootipText:"首页"
            onClicked: {
                console.log("回到首页")
                var listTab = multiTab.getTab(multiTab.currentIndex).item
                if(listTab.userinfo){
                Navigation.enterPath("/")
                pathNavRoot.switchPath("/")
                }
            }

        }
        CostomButton {
            height: parent.height * 0.6
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: 'images/add_hot.png'
            tootipText:"新建标签"
            onClicked: {
                console.log("添加新标签")
                multiTab.addTab("新建标签页",defaultTab)
                multiTab.currentIndex = multiTab.count - 1
                //更新 导航信息
                 Navigation.appNav.historyList = []
                 Navigation.appNav.historyIndex = -1
                 Navigation.appNav.pathInfo = []
                 Navigation.appNav.path = "&"
            }

        }
    }

    Row{
        anchors.left: btnhome.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height
        spacing: 0
        Repeater{
            id:repeaterview
            model:Navigation.appNav.pathInfo
            delegate: Label{
                id:dirName
                text:modelData.name
                elide:Text.ElideMiddle
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth,200) + sep.implicitWidth
                visible: index === 0 || repeaterview.model.length < 5 || index >= repeaterview.model.length - 3
                color: pathMa.containsMouse ? '#5c9fff' : 'black'
                MouseArea {
                    id: pathMa
                    width: parent.width - sep.implicitWidth
                    height: parent.height
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                       var path = modelData.path
                      Navigation.enterPath(path)
                      console.log(path)
                    }
                }
                Label {
                    id: sep
                    visible: index !== repeaterview.model.length - 1
                    text: repeaterview.model.length >= 5 && index === 0 ? ' > ··· > ' : ' > '
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: '#3887ff'
                }
            }
        }
    }
    function switchPath(path){
        var listTab = multiTab.getTab(multiTab.currentIndex).item
        if(listTab.userinfo){
            listTab.switchDir(path)
        }
    }
    Component.onCompleted: {
        Navigation.appNav.clicked.connect(switchPath)
    }
}
