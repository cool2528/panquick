#ifndef SYSTEMTARYICON_H
#define SYSTEMTARYICON_H

#include <QObject>
#include <QSystemTrayIcon>
#include <QQuickItem>
#include <QAction>
class ActionItem:public QAction
{
    Q_OBJECT
public:
    explicit ActionItem(QAction *parent = 0);
public:
    Q_PROPERTY(QUrl icon READ icon WRITE setIcon NOTIFY iconChanged)
    QUrl icon() const;
signals:
    void iconChanged(QUrl icon);
public slots:
    void setIcon(QUrl icon);
private:
QUrl m_icon;
};
class SeparatorItem :public QObject
{
     Q_OBJECT
public:
    explicit SeparatorItem(QObject *parent = 0);
};
class TaryMenu :public QQuickItem
{
    Q_OBJECT
public:
    explicit TaryMenu(QQuickItem *parent = 0);
    Q_PROPERTY(int width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    int width() const;
    int height() const;
public slots:
    void setWidth(int width);
    void setHeight(int height);
    void addMenu(TaryMenu* menu);
    void addAction(ActionItem* Item);
    void addSeparator();
signals:
    void widthChanged(int width);
    void heightChanged(int height);
protected:
    void componentComplete();
private:
    friend class SystemTaryIcon;
    int m_width;
    int m_height;
    QMenu* mMenu;
};

class SystemTaryIcon : public QQuickItem
{
    Q_OBJECT
public:
    explicit SystemTaryIcon(QQuickItem *parent = 0);
    ~SystemTaryIcon();
    Q_PROPERTY(int x READ x CONSTANT)
    Q_PROPERTY(int y READ y CONSTANT)
    Q_PROPERTY(TaryMenu* menu READ menu WRITE setMenu)
    Q_PROPERTY(QUrl icon READ icon WRITE setIcon)
    Q_PROPERTY(QString toolTip READ toolTip WRITE setToolTip)
public:
    int x() const;
    int y() const;
    TaryMenu* menu() const;
    QUrl icon() const;
    QString toolTip() const;
signals:
    void trigger(); //单击激活托盘
public slots:
    void onActivated(QSystemTrayIcon::ActivationReason reason);
    void setIcon(QUrl icon);
    void setToolTip(QString & tip);
    void setMenu(TaryMenu* menu);
    void onVisibleChanged();
    void onExit();
private:
    QSystemTrayIcon* mSystemTary;
    TaryMenu* mMenu;
    QUrl mIcon;
    QString mTip;
};

#endif // SYSTEMTARYICON_H
