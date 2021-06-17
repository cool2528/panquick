#ifndef COOKIEMANGRE_H
#define COOKIEMANGRE_H

#include <QObject>
#include <QList>
class QWebEngineCookieStore;
class QNetworkCookieJar;
class QNetworkCookie;
class CookieMangre : public QObject
{
    Q_OBJECT
public:
    explicit CookieMangre(QObject *parent = 0);
public:
    Q_INVOKABLE QString getcookie(QString url);
    Q_INVOKABLE void monitor();
    Q_INVOKABLE void cleanCookie();
signals:

public slots:
private:
    QWebEngineCookieStore* cookieStore;
    QString mCookies;
    QNetworkCookieJar* mCookieJar;
    QList<QNetworkCookie> parseCookies(const QString& cookies);
};

#endif // COOKIEMANGRE_H
