import QtQuick 2.0

Item {
    id:navigat
    property string path: ''
    property var pathInfo: []
    property var historyList: []
    property int historyIndex: -1
    signal clicked(string path)
    onPathChanged: {
        navigat.clicked(path)
        if(path ==="/"){
            pathInfo = [{"path": '/',"name": '我的文件'}]
            return
        }
        if(path === "&"){
            pathInfo = []
            return
        }

        var dirs = path.split("/")
        var tempPath =""
        var arr = []
        dirs.forEach(function (dir, idx) {
            console.log(idx)
            tempPath += idx === 1 ? dir : '/' + dir
            arr.push({name:idx===0 ? "我的文件":dir,path:tempPath})
        })
        pathInfo = arr
    }
}
