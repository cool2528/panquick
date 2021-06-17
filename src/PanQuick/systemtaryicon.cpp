#include "systemtaryicon.h"
#include <QApplication>
#include <QMenu>
SystemTaryIcon::SystemTaryIcon(QQuickItem *parent) : QQuickItem(parent)
{
    setObjectName("SystemTaryIcon");
    mSystemTary = new QSystemTrayIcon(this);
    connect(mSystemTary,&QSystemTrayIcon::activated,this,&SystemTaryIcon::onActivated);
    connect(this,&SystemTaryIcon::visibleChanged,this,&SystemTaryIcon::onVisibleChanged);
    setVisible(false);
}

SystemTaryIcon::~SystemTaryIcon()
{
    if(mMenu){
        delete mMenu;
        mMenu = nullptr;
    }
}

int SystemTaryIcon::x() const
{
    return mSystemTary->geometry().x();
}

int SystemTaryIcon::y() const
{
    return mSystemTary->geometry().y();
}

TaryMenu *SystemTaryIcon::menu() const
{
    return mMenu;
}

QUrl SystemTaryIcon::icon() const
{
    return mIcon;
}

QString SystemTaryIcon::toolTip() const
{
    return mTip;
}

void SystemTaryIcon::onActivated(QSystemTrayIcon::ActivationReason reason)
{
    switch (reason)
     {
     case QSystemTrayIcon::DoubleClick:
         emit trigger();            //只有双击拖盘图标时发送trigger()信号, reason类似还有Context,MiddleClick,Unknow
     default:
         break;
     }
}

void SystemTaryIcon::setIcon(QUrl icon)
{
    if (mIcon == icon)
        return;
    QString str = icon.toLocalFile();
    if(str.isEmpty()) str = icon.toString();
    if(str.mid(0,3) == "qrc")
        str = str.mid(3,str.count() - 3);
    mSystemTary->setIcon(QIcon(str));
    mIcon = icon;
}

void SystemTaryIcon::setToolTip(QString &tip)
{
    if(mTip == tip)
        return;
    mTip = tip;
    mSystemTary->setToolTip(tip);
}

void SystemTaryIcon::setMenu(TaryMenu *menu)
{
    if(menu == mMenu)
        return;
    mSystemTary->setContextMenu(menu->mMenu);
    mMenu = menu;
}

void SystemTaryIcon::onVisibleChanged()
{
    mSystemTary->setVisible(isVisible());
}

void SystemTaryIcon::onExit()
{
    mSystemTary->hide();
    QApplication::exit(0);
}

ActionItem::ActionItem(QAction *parent): QAction(parent)
{
    setObjectName("ActionItem");
}
QUrl ActionItem::icon() const
{
    return m_icon;
}
void ActionItem::setIcon(QUrl icon)
{
    if (m_icon == icon)
        return;
    QString str = icon.toLocalFile();
    if(str.isEmpty()) str = icon.toString();
    if(str.mid(0,3) == "qrc")
        str = str.mid(3,str.count() - 3);
    QAction::setIcon(QIcon(str));
    m_icon = icon;
    emit iconChanged(icon);
}

SeparatorItem::SeparatorItem(QObject *parent):QObject(parent)
{
    setObjectName("SeparatorItem");
}

TaryMenu::TaryMenu(QQuickItem *parent):QQuickItem(parent)
{
    mMenu = new QMenu();
    setObjectName("TaryMenu");
}
void TaryMenu::setWidth(int width)
{
    if (m_width == width)
        return;

    m_width = width;
    mMenu->setFixedWidth(width);
    emit widthChanged(width);
}
int TaryMenu::width() const
{
    return m_width;
}
int TaryMenu::height() const
{
    return m_height;
}
void TaryMenu::setHeight(int height)
{
    if (m_height == height)
        return;

    m_height = height;
    mMenu->setFixedHeight(height);
    emit heightChanged(height);
}

void TaryMenu::addMenu(TaryMenu *menu)
{
    mMenu->addMenu(menu->mMenu);
}

void TaryMenu::addAction(ActionItem *Item)
{
    mMenu->addAction(Item);
}

void TaryMenu::addSeparator()
{
    mMenu->addSeparator();
}

void TaryMenu::componentComplete()
{
    QQuickItem::componentComplete();
       QObjectList list = children();
       for (auto it : list)
       {
           if (it->objectName() == "ActionItem")
           {
               auto action = qobject_cast<ActionItem *>(it);
               mMenu->addAction(action);
           }
           else if (it->objectName() == "SeparatorItem")
           {
               mMenu->addSeparator();
           }
           else if (it->objectName() == "TaryMenu")
           {
               auto menu = qobject_cast<TaryMenu *>(it);
               mMenu->addMenu(menu->mMenu);
           }
       }
}
