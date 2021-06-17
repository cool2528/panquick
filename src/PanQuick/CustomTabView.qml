import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
TabView{
   style: TabViewStyle{
        frameOverlap: 1
        tab:Item {
            implicitWidth:Math.max(titleMsg.width + 4,control.width / control.count)
            implicitHeight: 40
            //选中后的前景色区域
            Rectangle{
                color:globalobj.forecolor
                width:(styleData.index < control.count -1) ?(parent.width -2):parent.width
                height: parent.height - 4
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 1
                visible: styleData.selected
            }
            //显示标签的文本
            Item{
                implicitHeight: parent.height
                implicitWidth: parent.width
                anchors.centerIn: parent
                Text{
                    anchors.centerIn: parent
                    font.pixelSize: 15
                    maximumLineCount: 1
                    elide: Text.ElideLeft
                    wrapMode: Text.Wrap
                    id:titleMsg
                    text:styleData.title
                    color:styleData.selected ? "#80A7FA" : "#333333"
                }
            }
            //显示选中后标签底部的状态条
            Rectangle{
                height: 4
                width:titleMsg.width + 10
                anchors.bottom:parent.bottom
                anchors.bottomMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                visible: styleData.selected
                color:"#06A8FF"
            }
        }
        //标签的样式
        frame:Rectangle{
            width:parent.width
            height:parent.height + 40
            gradient: Gradient{
                                 GradientStop{position: 0.0;color: globalobj.gradualcolorone;}
                                 GradientStop{position: 0.3;color: globalobj.gradualcolortwo;}
                                 GradientStop{position: 1.0;color: globalobj.gradualcolorthree;}
                             }
        }

        //选中用户的背景色
        tabBar: Rectangle{
            height: 40
            color:globalobj.backgroundcolor
        }

    }
}
