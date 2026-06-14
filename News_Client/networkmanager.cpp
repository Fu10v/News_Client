#include "networkmanager.h"
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent), m_manager(new QNetworkAccessManager(this))
{
    connect(m_manager, &QNetworkAccessManager::finished, this, &NetworkManager::onReplyFinished);
}

void NetworkManager::sendApiRequest()
{
    QUrl url("https://newsapi.org/v2/top-headlines");
    QUrlQuery urlQuery;

    urlQuery.addQueryItem("apiKey", API_KEY); 

    if (m_currentLang == "en") {
        urlQuery.addQueryItem("country", "us");
    } else {
        urlQuery.addQueryItem("country", "ua");
    }

    if (!m_currentCategory.isEmpty()) {
        urlQuery.addQueryItem("category", m_currentCategory);
    }
    if (!m_currentQuery.isEmpty()) {
        urlQuery.addQueryItem("q", m_currentQuery);
    }

    urlQuery.addQueryItem("page", QString::number(m_currentPage));
    urlQuery.addQueryItem("pageSize", "20");

    url.setQuery(urlQuery);
    QNetworkRequest request(url);
    m_manager->get(request);
}

void NetworkManager::fetchNews(const QString &searchQuery, const QString &category, const QString &lang)
{
    if (m_isLoading) return;
    m_isLoading = true;
    m_currentPage = 1;
    m_currentQuery = searchQuery;
    m_currentCategory = category;
    m_currentLang = lang;

    sendApiRequest();
}

void NetworkManager::loadMoreNews()
{
    if (m_isLoading) return;
    m_isLoading = true;
    m_currentPage++;
    qDebug() << "Завантаження сторінки №" << m_currentPage;
    sendApiRequest();
}

void NetworkManager::onReplyFinished(QNetworkReply *reply)
{
    m_isLoading = false;
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray responseData = reply->readAll();
        if (m_currentPage == 1) {
            emit dataReady(responseData);
        } else {
            emit moreDataReady(responseData);
        }

    } else {
        qWarning() << "Помилка мережі:" << reply->errorString();
        emit errorOccurred(reply->errorString());
    }
    reply->deleteLater();
}
