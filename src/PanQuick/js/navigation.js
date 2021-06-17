.pragma library
var appNav = (function(){
    var Component = Qt.createComponent("./navigatQml.qml")
    return Component.createObject()
})()

function enterPath(path,isHistory){
    appNav.path = path
    //console.log(appState)
    if(isHistory || path === appNav.historyList[appNav.historyIndex]){
        return
    }
    if(appNav.historyIndex !== appNav.historyList.length -1){
        for(var i=0;i < appNav.historyList.length - appNav.historyIndex;i++){
            appNav.historyList.pop()
        }
    }
    appNav.historyList.push(path)
    appNav.historyIndex = appNav.historyList.length - 1
}
//前进
function goForward(){
    var path = appNav.historyList[appNav.historyIndex+1]
    console.log(path)
    if(path){
        enterPath(path,true)
    }
    appNav.historyIndex++
}
//后退
function retreat(){
    var path = appNav.historyList[appNav.historyIndex - 1]
     console.log(path)
    if(path){
        enterPath(path,true)
    }
    appNav.historyIndex--
}
