import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Item {
    id:downloadManage
    property alias model: listview.model
    width:parent.width
    height: parent.width
    Component{
        id:listDelegate
        Item {
            id: wrapper
            width: parent.width
            height: 60
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    listview.currentIndex = index
                    console.log(listview.currentIndex,index)
                    console.log(wrapper.ListView.isCurrentItem)
                }
            }
            Rectangle{
                anchors.left: parent.left
                width: parent.width
                height: parent.height
                color: wrapper.ListView.isCurrentItem ? "#C5E6FF" :"#E5F3FF"
                //文件类型图标
                Image {
                    id: icon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 48
                    height: 48
                    source: "images/"+ type +".png"
                }
                //文件的名称
                Text {
                    id: fileTitle
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.left: icon.right
                    anchors.leftMargin: 10
                    text: name
                    font.family: "微软雅黑"
                    color:"#333333"
                }
                //文件当前大下与总大小
                Text {
                    id: fileSize
                    anchors.top: fileTitle.bottom
                    anchors.topMargin: 5
                    anchors.left: fileTitle.left
                    text: sizeStatus
                    font.family: "微软雅黑"
                    color:"#333333"
                }
                //进度条
                ProgressBar {
                    id:progress
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width / 5 * 2.5
                    anchors.top: fileTitle.top
                    maximumValue:100
                    minimumValue:0
                    value:proValue
                    style: ProgressBarStyle {
                        background: Rectangle {
                            radius: 2
                            color: "#D3E5F1"
                            implicitWidth: 150
                            implicitHeight: 15
                        }
                        progress: Rectangle {
                            color: "#55A7FA"
                            border.color: "steelblue"
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        id: values
                        text: progress.value + " %"
                        font.family: "微软雅黑"
                        color:"#333333"
                    }
                }
                //文件下载剩余时间
                Text{
                    id:residusTime
                    anchors.top: progress.bottom
                    anchors.topMargin: 5
                    anchors.left: progress.left
                    font.family: "微软雅黑"
                    text: status ? downloadTime : "--:--:--"
                    color:"#333333"
                }
                //下载速度/状态
                Text{
                    id:downloadSpeedStatus
                    anchors.left: progress.right
                    anchors.leftMargin: 50
                    anchors.verticalCenter: parent.verticalCenter
                    text: textStatus
                    font.family: "微软雅黑"
                    color:"#333333"
                }
                //开始暂停按钮
                CostomButton{
                    id:startBtn
                    width: 32
                    height: 32
                    anchors.left: downloadSpeedStatus.right
                    anchors.leftMargin: 50
                    anchors.verticalCenter: parent.verticalCenter
                    tootipText:status ? "暂停" : "开始"
                    source:status ? "images/dl_pause.png" :"images/dl_start.png"
                    normalUrl:status ? "images/dl_pause.png" :"images/dl_start.png"
                    hoveredUrl:status ? "images/dl_pause_hot.png" :"images/dl_start_hot.png"
                    onClicked: {
                        console.log("暂停/开始被单击")
                    }
                }
                //删除按钮
                CostomButton{
                    id:delBtn
                    anchors.left: startBtn.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    tootipText:"取消"
                    source:"images/dl_stop.png"
                    normalUrl:"images/dl_stop.png"
                    hoveredUrl:"images/dl_stop_hot.png"
                    onClicked: {
                        console.log("取消被单击")
                    }
                }
            }
        }
    }
    //list
    ListView{
        id:listview
        anchors.fill: parent
        delegate:listDelegate
        focus: true
    }
}
