#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class NetworkManager : public QObject
{
    Q_OBJECT

public:
    explicit NetworkManager(QObject *parent = nullptr);

    // Метод для запуску завантаження новин (викличеться з ядра програми)
    Q_INVOKABLE void fetchNews(const QString &searchQuery = "",
                                    const QString &category = "general",
                                    const QString &lang = "en");
    Q_INVOKABLE void loadMoreNews();

signals:
    // Сигнали, які відправляємо, коли щось сталось
    void dataReady(const QByteArray &data);     // Дані успішно отримані
    void errorOccurred(const QString &errorMsg); // Сталася помилка (немає інтернету тощо)
    void moreDataReady(const QByteArray &data);


private slots:
    // Внутрішній слот (обробник) для прийому відповіді від сервера
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_manager; // Головний клас Qt для роботи з мережею
    int m_currentPage = 1;
    bool m_isLoading = false;
    QString m_currentQuery = "";
    QString m_currentCategory = "general";
    QString m_currentLang = "en";
    void sendApiRequest();

    // Константи для API
    const QString API_KEY = "1fcb58649b1b40ab9a3115c5c55a1019"; // Сюди треба вставити ключ з newsapi.org
    const QString BASE_URL = "https://newsapi.org/v2/top-headlines";
};

#endif
