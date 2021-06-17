#include "treeitem.h"
#include <QDebug>
TreeItem::TreeItem():mParentRoot(nullptr)
{

}

TreeItem::TreeItem(const QHash<ItemRoles,QVariant> & data,TreeItemPtr parent):mParentRoot(parent)
{
    mItemData = data;
}

TreeItem::~TreeItem()
{
    qDeleteAll(mChild.begin(),mChild.end());
}

int TreeItem::count() const
{
    return mChild.size();
}

void TreeItem::appendChild(TreeItemPtr childItem)
{
    if(childItem){
           childItem->setParent(this);
           mChild.push_back(childItem);
    }
}

void TreeItem::setParent(TreeItemPtr parent)
{
    mParentRoot = parent;
}

TreeItemPtr TreeItem::getParent() const
{
    return mParentRoot;
}

void TreeItem::removeChild(int row)
{
    if(row < mChild.size() && row > -1){
       auto item =  mChild.at(row);
       qDebug() << item->count() << endl;
       item->deleteAllChild();
       mChild.removeAt(row);
       qDebug()<< mChild.size() << endl;
       delete item;
       item = nullptr;
    }
}

void TreeItem::insertChild(int row,TreeItemPtr item)
{
    if(row >= mChild.size()){
        return;
    }
    item->setParent(this);
    mChild.insert(row,item);
}

void TreeItem::deleteAllChild()
{
    qDeleteAll(mChild);
    mChild.clear();
}

void TreeItem::setData(int roles,const QVariant& data)
{
    mItemData[ItemRoles(roles)] = data;
}

TreeItemPtr TreeItem::getChild(int row)
{
    TreeItemPtr result = nullptr;
    if(row < mChild.size() && row > -1){
       result = mChild.at(row);
    }
    return result;
}

QVariant TreeItem::data(int roles) const
{
    return mItemData[ItemRoles(roles)];
}

int TreeItem::row()
{
    if(!mParentRoot){
        return 0;
    }
    return mChild.indexOf(this);
}
