#include "systeminterface.h"
#include <QClipboard>
#include <QApplication>
SystemInterface::SystemInterface(QObject *parent) : QObject(parent)
{

}

QString SystemInterface::getClipboard()
{
    QClipboard* board = QApplication::clipboard();
    return board->text();
}

void SystemInterface::setClipboard(const QString &text)
{
    QClipboard* board = QApplication::clipboard();
    board->setText(text);
}
