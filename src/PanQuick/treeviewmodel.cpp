#include "treeviewmodel.h"
#include <QRegExp>
#include "httprequest.h"
#include "nlohmann/json.hpp"
using json = nlohmann::json;
TreeViewModel::TreeViewModel(QObject *parent)
    : QAbstractItemModel(parent)
{
    mRootTree = new TreeItem();
    auto allFilePath  = new TreeItem();
    allFilePath->setData(path,"/");
    allFilePath->setData(empty,1);
    allFilePath->setData(name,QStringLiteral("全部文件"));
    mRootTree->appendChild(allFilePath);
}

TreeViewModel::~TreeViewModel()
{
    if(mRootTree){
        delete mRootTree;
        mRootTree = nullptr;
    }
}

QModelIndex TreeViewModel::index(int row, int column, const QModelIndex &parent) const
{
    // FIXME: Implement me!
    if(!hasIndex(row,column,parent)){
        return QModelIndex();
    }
    TreeItemPtr parentItem = nullptr;
    if(parent.isValid()){

        parentItem = static_cast<TreeItemPtr>(parent.internalPointer());
    }else{
        parentItem = mRootTree;
    }
    TreeItemPtr ChildItem = parentItem->getChild(row);
    if(ChildItem){
        return createIndex(row,column,ChildItem);
    }else{

        return QModelIndex();
    }
}

QModelIndex TreeViewModel::parent(const QModelIndex &index) const
{
    // FIXME: Implement me!
    QModelIndex result;
    if(index.isValid()){
        auto ChildItem = static_cast<TreeItemPtr>(index.internalPointer());
        auto ParentItem = ChildItem->getParent();
        if(ParentItem == nullptr){
            return result;
        }else{
            result = createIndex(ParentItem->row(),0,ParentItem);
        }
    }
    return result;
}

int TreeViewModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid()){
        return mRootTree->count();
    }
    auto rootItem = static_cast<TreeItemPtr>(parent.internalPointer());
    return rootItem->count();
    // FIXME: Implement me!
}

int TreeViewModel::columnCount(const QModelIndex &parent) const
{
    return 1;
    if (!parent.isValid())
        return 0;
    // FIXME: Implement me!
}

QVariant TreeViewModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    // FIXME: Implement me!
    auto itemPtr = static_cast<TreeItemPtr>(index.internalPointer());
    return itemPtr->data(role);
}

QHash<int, QByteArray> TreeViewModel::roleNames() const
{
    //角色名称
    QHash<int,QByteArray> roleName;
    roleName[path] = "path";
    roleName[empty] = "empty";
    roleName[name] = "name";
    return roleName;
}

bool TreeViewModel::hasChildren(const QModelIndex &parent) const
{
    bool result = false;
    if(!parent.isValid()){
        return result;
    }
    TreeItemPtr item = static_cast<TreeItemPtr>(parent.internalPointer());
    result = item->data(empty).toInt() > 0 ? true :false;
    return result;
}
qint32 TreeViewModel::loderData(const QString& cookies,const QModelIndex &parent)
{
    qint32 numbercount = 0;
    if(!parent.isValid()){
        return  numbercount;
    }
   auto strPath = parent.data(path).toString();
   if(strPath.isEmpty()){
       return numbercount;
   }
   int count = rowCount(parent);
   //有的话先删除
   if(count){
       numbercount = count;
       return numbercount;
       //或者你也可以每次展开删除原来的从新获取
       TreeItemPtr item = static_cast<TreeItemPtr>(parent.internalPointer());
       beginRemoveRows(parent,0,count);
	   item->deleteAllChild();
       endRemoveRows();
   }else{
       //准备读取目录数据添加
       QString jsondata = getDiectoryData(cookies,parent.data(path).toString());
       json dc = json::parse(jsondata.toStdString().c_str());
       if(!dc.is_structured()){
           return  numbercount;
       }
       if(dc["list"].is_array()){
           numbercount = dc["list"].size();
           TreeItemPtr item = static_cast<TreeItemPtr>(parent.internalPointer());
           beginInsertRows(parent,0,numbercount);
           for (auto v: dc["list"]) {
               QString paths,names;
               unsigned int emptys = 0;
               if(v.is_object()){
                   if(v["path"].is_string()){
                       paths = QString::fromStdString(v["path"].get<std::string>());
                   }
                   if(v["dir_empty"].is_number_unsigned()){
                       emptys = v["dir_empty"].get<unsigned int>();
                   }
                   TreeItemPtr child = new TreeItem();
                   int pos = paths.lastIndexOf("/");
                   if(pos!=-1){
                     names = paths.right(paths.length() - (pos + 1));
                   }
                   child->setData(path,paths);
                   child->setData(empty,!emptys);
                   child->setData(name,names);
                   item->appendChild(child);
               }
           }
           endInsertRows();
       }
   }
   return numbercount;
}

QString TreeViewModel::getIndexData(const QModelIndex &index)
{
    QString strResult;
    if(!index.isValid()){
        return strResult;
    }
    strResult = index.data(path).toString();
    return strResult;
}

QString TreeViewModel::getDiectoryData(const QString &cookies,const QString& path)
{
    QString strResult;
    if(cookies.isEmpty()){
        return strResult;
    }
    HttpRequest baidu;
    baidu.setRequestHeader("Referer","https://pan.baidu.com/disk/home");
    baidu.setRequestHeader("Accept","*/*");
    baidu.setRequestHeader("Cookie",cookies);
    baidu.setRequestHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36");
    baidu.send(GET,"https://pan.baidu.com/disk/home");
    auto Content = baidu.getBodyContent();
    QRegExp userRegex("var\\scontext=(.*);\\s");
    userRegex.setMinimal(true);
    if (!userRegex.isValid())
    {
        return strResult;
    }
    std::string bdstoken;
    int pos = userRegex.indexIn(Content);
    if(pos > -1){
        QString qsUserinfo = userRegex.cap(1);
        json dc = json::parse(qsUserinfo.toStdString().c_str());
        if(!dc.is_structured()){
            return strResult;
        }
        if(dc["bdstoken"].is_string()){
            bdstoken = dc["bdstoken"].get<std::string>();
        }
        QString strUrl = QString("https://pan.baidu.com/api/list?app_id=250528&bdstoken=%1&channel=chunlei&clienttype=0&desc=0&dir=%2&folder=1&num=500&order=name&page=0&showempty=0&web=1").arg(bdstoken.c_str()).arg(UrlCoding(path));
        qDebug() << strUrl << endl;
        baidu.setRequestHeader("Referer","https://pan.baidu.com/disk/home");
		baidu.setRequestHeader("Content-Type", "text/html");
        baidu.setRequestHeader("Accept","*/*");
        baidu.setRequestHeader("Cookie",cookies);
        baidu.setRequestHeader("User-Agent","Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0");
        baidu.send(GET,strUrl);
        strResult = baidu.getBodyContent();
    }
    return strResult;
}

QString TreeViewModel::UrlCoding(const QString &data)
{
    QString result;
    QByteArray tmpData = data.toUtf8();
    result = tmpData.toPercentEncoding(" ").data();
    return result;
}



