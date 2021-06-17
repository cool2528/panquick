import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Item{
    id:tableRoot
    property alias model: tableViewtest.model
    property var fileinfo: {}   //文件信息
    property bool loadStatus: true //是否处于加载状态

    BusyIndicator{
        id:busy
        running: tableRoot.loadStatus
        anchors.centerIn: parent
        z:2
    }

    //成功信息提示框
    SucceedToolTip{
        id:succeedMsgTooltip
    }
    //失败信息提示框
    WarningToolTip{
        id:warningMsgTooltip
    }

    TableView{
        id:tableViewtest
        width:parent.width
        height: parent.height - 42
        property real localX: 0
        property real localY: 0
        property bool allcheck: false
        horizontalScrollBarPolicy:Qt.ScrollBarAsNeeded
        TableViewColumn{
            role:"check"
            title:""
            width:25
            movable:false
            resizable:false
        }
        TableViewColumn{
            role:"type"
            title:""
            width:32
            movable:false
            resizable:false
        }
        TableViewColumn{
            role:"name"
            title:"文件名"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount * 2
        }
        TableViewColumn{
            role:"size"
            title:"大小"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount /1.5
        }
        TableViewColumn{
            role:"timer"
            title:"修改时间"
            movable:false
            resizable:false
            width:tableViewtest.width / tableViewtest.columnCount /1.0
        }
        alternatingRowColors:false
        model:ListModel{

        }
        style:TableViewStyle{
            backgroundColor:"#D7EFFF"
            headerDelegate:  Rectangle{
                implicitWidth: 200
                implicitHeight: 30
                color:"#D7EFFF"
                border.color: "#D2E7F5"
                border.width: 1
                //visible: styleData.column!==0 ? true :false
                CheckBox{
                    anchors.left: parent.left
                    anchors.margins: 5
                    text:""
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 15
                    implicitHeight:15
                    visible: !styleData.column
                    checked:tableViewtest.allcheck
                    style:CheckBoxStyle{
                        indicator:Rectangle{
                            implicitHeight: 15
                            implicitWidth: 15
                            border.color: control.activeFocus  ? "#06A8FF":"#B3B3B3"
                            border.width: 2
                            Image {
                                visible: control.checked
                                source: "images/selected.png"

                            }
                        }
                    }
                }
                Text{
                    visible: styleData.column!==0 ? true :false
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text:styleData.value
                }
            }
            itemDelegate:Rectangle{
                id:rowitem
                implicitWidth: 200
                implicitHeight: 20
                color:styleData.selected ? "#C7E6FF": "#D7EFFF"
                CheckBox{
                    id:checkbox
                    anchors.left: parent.left
                    anchors.margins: 5
                    text:""
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: 15
                    implicitHeight:15
                    visible: !styleData.column
                    checked:styleData.value
                    style:CheckBoxStyle{
                        indicator:Rectangle{
                            implicitHeight: 15
                            implicitWidth: 15
                            border.color: control.activeFocus  ? "#06A8FF":"#B3B3B3"
                            border.width: 2
                            Image {
                                visible: control.checked
                                source: "images/selected.png"

                            }
                        }
                    }
                }
                Image{
                    id:iconimage
                    anchors.left:checkbox.right
                    anchors.leftMargin: -20
                    visible: styleData.column === 1 ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    source: styleData.column ===1 && styleData.value!=="" ? "images/" + styleData.value + ".png" :""
                }
                Text{
                    visible: styleData.column > 1 ? true : false
                    anchors.left:iconimage.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text:styleData.value
                }
            }
            rowDelegate:Rectangle{
                color:"#D7EFFF"
                height: 30
            }
        }
        //右键菜单
        MouseArea{
            anchors.left: parent.left
            anchors.leftMargin: 20
            height: parent.height
            anchors.right: parent.right
            acceptedButtons:Qt.RightButton
            onClicked: {
                if(mouse.button === Qt.RightButton){
                    tableViewtest.localX = mouseX
                    tableViewtest.localY = mouseY
                    console.log(mouseX,mouseY)
                    var row = tableViewtest.rowAt(tableViewtest.localX,tableViewtest.localY)
                    option_empty_menu.popup()
                    mouse.accepted = true

                }
            }


            ListMenu{
                id:option_empty_menu
                MenuItem{
                    text:"下载"
                    onTriggered: {
                        console.log("下载")
                        var jsondata = {};
                        jsondata.Cookie = tableRoot.fileinfo.Cookie
                        jsondata.shareid = tableRoot.fileinfo.shareid
                        jsondata.uk = tableRoot.fileinfo.uk
                        jsondata.sign = tableRoot.fileinfo.sign
                        var listFile = []
                        for(var k = 0; k < tableViewtest.model.count;++k){
                            var tmpObj = tableViewtest.model.get(k)
                            if(tmpObj && tmpObj.check === true){
                                listFile.push(tmpObj.fs_id)
                            }
                        }
                        jsondata.list = listFile
                        var strjsondata = JSON.stringify(jsondata);
                        var result = baidu.getDownloadShareInfo(strjsondata,"");
                        console.log(result)

                    }
                }
                MenuItem{
                    text:"新建文件夹"
                    onTriggered: {
                        console.log("新建文件夹")
                    }
                }
            }
        }
        //左键单击选中
        MouseArea{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: tableViewtest.width - 20
            height: parent.height
            hoverEnabled:true
            acceptedButtons: Qt.LeftButton
            onClicked: {
                console.log("-------------")
                tableViewtest.localX = mouseX
                tableViewtest.localY = mouseY
                console.log(mouseX,mouseY)
                var row = tableViewtest.rowAt(tableViewtest.localX,tableViewtest.localY)
                if(row >=0){
                    tableViewtest.clicked(row)
                }
                if(tableViewtest.localY < 30){
                    tableViewtest.allcheck = ! tableViewtest.allcheck
                    console.log(tableViewtest.localY)
                    for(var i = 0;i < tableViewtest.model.count;i++){
                        tableViewtest.model.setProperty(i,"check",tableViewtest.allcheck)
                    }
                }

                mouse.accepted = true
            }
        }
        //table单击事件
        onClicked:{
            tableViewtest.currentRow = row
            var isCheck = tableViewtest.model.get(row).check
            tableViewtest.model.setProperty(row,"check",!isCheck)
            if(!isCheck){
                tableViewtest.selection.select(row)
            }else{
                tableViewtest.selection.deselect(row)
            }
        }
        //双击事件
        onDoubleClicked:{
            var isDir = tableViewtest.model.get(row).isdir
            if(isDir){
                var path = tableViewtest.model.get(row).path
                var name = tableViewtest.model.get(row).name
                tableRoot.switchDir(path)
            }
        }
        Component.onCompleted: {
            console.log("width "+tableRoot.width,"height  "+tableRoot.height)
        }
    }
    function initFileList(filelist){
        tableRoot.loadStatus = true
        tableViewtest.model.clear()
        if(filelist.list){
            tableRoot.fileinfo = filelist
            for (var x in filelist.list){
                tableViewtest.model.append(filelist.list[x])
                console.log(JSON.stringify(filelist.list[x]))
            }
        }
        tableRoot.loadStatus = false
    }
    //切换目录
    function switchDir(listPath){
        tableRoot.loadStatus = true
        tableViewtest.model.clear()
        var result = baidu.getShareFilePath(tableRoot.fileinfo.Cookie,listPath,tableRoot.fileinfo.shareid,tableRoot.fileinfo.uk)
        var filelist = JSON.parse(result)
        if(filelist.list){
            for (var x in filelist.list){
                tableViewtest.model.append(filelist.list[x])
                console.log(JSON.stringify(filelist.list[x]))
            }
        }
        tableRoot.loadStatus = false
    }
}

