#ifndef TREEITEM_H
#define TREEITEM_H
class TreeItem;
typedef TreeItem* TreeItemPtr;
#include <QVariant>
#include <QList>
enum ItemRoles{
    name = Qt::UserRole + 1,
    empty,
    path
};
class TreeItem
{
public:
    TreeItem();
    TreeItem(const QHash<ItemRoles,QVariant>& data,TreeItemPtr parent = nullptr);
    ~TreeItem();
    int count() const;  //当前节点的子节点数量
    void appendChild(TreeItemPtr childItem);    //添加 子节点
    void setParent(TreeItemPtr parent); //设置父节点
    TreeItemPtr getParent() const;  //获取父节点
    void removeChild(int row); // 移除指定位置的节点
    void insertChild(int row,TreeItemPtr item);  //插入节点
    void deleteAllChild();  //清空所有节点
    void setData(int roles,const QVariant& data); //设置数据
    TreeItemPtr getChild(int row); //获取指定子节点
    QVariant data(int roles) const;  //获取data
    int row();
private:
    TreeItemPtr mParentRoot;    //当前节点的父节点
    QHash<ItemRoles,QVariant>  mItemData; //当前节点的数据
    QList<TreeItemPtr> mChild;  //当前节点的子节点
};

#endif // TREEITEM_H
