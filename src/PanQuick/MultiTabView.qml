import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.0
TabView{
    id:viewtab
    width:parent.width
    height:parent.height
    signal deleteTab(int index)
    signal selectTab(int index)
    style: TabViewStyle{
        frameOverlap: 1
        id:viewTab
        property string urlPath: "/images/Tarylogo.ico"
        tab:Item {
            implicitWidth:Math.max(titleMsg.width + 4,120)
            implicitHeight: 30
            //选中后的前景色区域
            Rectangle{
                color:"#C6DEEF"
                width:(styleData.index < control.count -1) ?(parent.width -2):parent.width
                height: parent.height - 4
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 1
                visible: styleData.selected
            }
            //悬停的前景色区域
            Rectangle{
                color:"#CEE7F9"
                width:(styleData.index < control.count -1) ?(parent.width -2):parent.width
                height: parent.height - 4
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 1
                visible: styleData.hovered
            }
            //显示标签的文本
            Item{
                implicitHeight: parent.height
                implicitWidth: parent.width
                anchors.centerIn: parent
                Rectangle{
                    id:itemTab
                    anchors.fill: parent
                    border.color: "#CBE4F5"
                    color:"#00000000"
                    border.width: 1
                    Image {
                        id: facicon
                        source: viewTab.urlPath
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        verticalAlignment:Image.AlignVCenter
                        horizontalAlignment:Image.AlignHCenter
                    }
                    Text{
                        anchors.centerIn: parent
                        font.pixelSize: 15
                        id:titleMsg
                        maximumLineCount: 1
                        width:60
                        wrapMode: Text.WrapAnywhere
                        text:styleData.title
                        color:styleData.selected ? "#3A83E1" : "#333333"
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: toolTipMsg.visible = true
                            onExited: toolTipMsg.visible = false
                        }
                    }
                    ToolTip{
                        id:toolTipMsg
                        text:styleData.title
                        timeout: 1000
                    }

                    //删除tab按钮
                    CostomButton{
                         visible: styleData.hovered
                         anchors.left: titleMsg.right
                         anchors.leftMargin: 5
                         height: parent.height
                         width: parent.height
                         source: styleData.hovered ? "images/close2_normal.png" : "images/close2_pushed.png"
                         tootipText:"关闭标签"
                         onClicked:{
                             viewtab.deleteTab(styleData.index)
                         }
                    }
                    MouseArea{
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        onClicked: {
                            console.log(styleData.index)
                            viewtab.selectTab(styleData.index)
                        }
                    }
                }
            }
        }
        //选中用户的背景色
        tabBar: Rectangle{
            height: 30
            color:globalobj.backgroundcolor
        }
        //标签的样式
        frame:Rectangle{
            width:parent.width
            height:parent.height
            gradient: Gradient{
                                 GradientStop{position: 0.0;color: globalobj.gradualcolorone;}
                                 GradientStop{position: 0.3;color: globalobj.gradualcolortwo;}
                                 GradientStop{position: 1.0;color: globalobj.gradualcolorthree;}
                             }
            Component.onCompleted: {
                console.log("frame:Rectangle 高度："+height,"宽度："+width)
            }
        }
}

}
