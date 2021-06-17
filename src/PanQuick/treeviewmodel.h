#ifndef TREEVIEWMODEL_H
#define TREEVIEWMODEL_H

#include <QAbstractItemModel>
#include "treeitem.h"
class TreeViewModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit TreeViewModel(QObject *parent = 0);
    ~TreeViewModel();
    // Basic functionality:
    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = name) const override;
    QHash<int,QByteArray> roleNames() const override;
    bool hasChildren(const QModelIndex &parent) const override;
   Q_INVOKABLE qint32 loderData(const QString& cookies,const QModelIndex& parent);
   Q_INVOKABLE QString getIndexData(const QModelIndex& index);
private:
    TreeItemPtr mRootTree;
    QString getDiectoryData(const QString& cookies,const QString& path);
    QString  UrlCoding(const QString& data);
};

#endif // TREEVIEWMODEL_H
