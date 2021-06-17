import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
Menu{
    id:menuview
    style: MenuStyle{
        frame: Rectangle{
            implicitWidth: 120
            implicitHeight: 350
            color:"#FBFBFB"
            border.color:"#303132"
            border.width: 1
            radius: 3
        }
        itemDelegate.background: Rectangle{
            implicitWidth:120
            implicitHeight: 20
            color:styleData.selected ? "#EFF4FB" :"#FBFBFB"
        }
        itemDelegate.label: RowLayout{
            height: 20
            spacing: 1
            Image{
                fillMode: Image.PreserveAspectFit
                visible: styleData.iconSource !==""
                source: styleData.iconSource
            }
            Text{
                text:styleData.text
                color:styleData.selected ? "#4FB2FC":"#333333"
                horizontalAlignment:Text.AlignHCenter
            }
        }
    }
}

