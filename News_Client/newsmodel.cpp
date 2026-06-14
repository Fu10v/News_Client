#include "NewsModel.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

NewsModel::NewsModel(QObject *parent) : QAbstractListModel(parent) {}

int NewsModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_articles.count();
}

QVariant NewsModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_articles.count())
        return QVariant();

    const Article &article = m_articles[index.row()];

    switch (role) {
        case TitleRole: return article.title;
        case DescriptionRole: return article.description;
        case UrlRole: return article.url;
        case ImageUrlRole: return article.imageUrl;
        case DateRole: return article.publishedAt;
        case SourceRole: return article.sourceName;
        case ContentRole: return article.content; 
    }
    return QVariant();
}

QHash<int, QByteArray> NewsModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "titleText";
    roles[DescriptionRole] = "descriptionText";
    roles[UrlRole] = "url";
    roles[ImageUrlRole] = "imageUrl";
    roles[DateRole] = "dateText";
    roles[SourceRole] = "sourceText";
    roles[ContentRole] = "contentText";
    return roles;
}


void NewsModel::parseJson(const QByteArray &jsonData) {
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &error);

    if (error.error != QJsonParseError::NoError) return;
    QJsonObject rootObj = doc.object();
    if (rootObj.value("status").toString() != "ok") return;

    QJsonArray articlesArray = rootObj.value("articles").toArray();

    m_allArticles.clear();
    QStringList newSourceList;
    newSourceList.append("All sources");

    for (const QJsonValue &val : articlesArray) {
        QJsonObject obj = val.toObject();
        Article article;

        article.title = obj.value("title").toString();
        article.description = obj.value("description").toString();
        article.url = obj.value("url").toString();
        article.imageUrl = obj.value("urlToImage").toString();

        QString rawDate = obj.value("publishedAt").toString();
        article.publishedAt = rawDate.replace("T", " ").replace("Z", "");

        QJsonObject sourceObj = obj.value("source").toObject();
        article.sourceName = sourceObj.value("name").toString();
        article.content = obj.value("content").toString();

        m_allArticles.append(article);

        if (!newSourceList.contains(article.sourceName) && !article.sourceName.isEmpty()) {
            newSourceList.append(article.sourceName);
        }
    }

    m_sourceList = newSourceList;
    emit sourceListChanged();

    applyFilters(0, "All sources");
}

void NewsModel::applyFilters(int sortIndex, const QString &sourceFilter) {
    m_currentSortIndex = sortIndex;
    m_currentSourceFilter = sourceFilter;

    beginResetModel();
    m_articles.clear();
    beginResetModel();
    m_articles.clear();

    for (const Article &article : m_allArticles) {
        if (sourceFilter == "All sources" || sourceFilter == "Усі джерела" || article.sourceName == sourceFilter) {
            m_articles.append(article);
        }
    }

    if (sortIndex == 0) {
        std::sort(m_articles.begin(), m_articles.end(), [](const Article &a, const Article &b) {
            return a.publishedAt > b.publishedAt;
        });
    } else if (sortIndex == 1) {
        std::sort(m_articles.begin(), m_articles.end(), [](const Article &a, const Article &b) {
            return a.publishedAt < b.publishedAt;
        });
    }


    endResetModel();
}

void NewsModel::appendJson(const QByteArray &jsonData) {
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(jsonData, &error);

    if (error.error != QJsonParseError::NoError) return;
    QJsonObject rootObj = doc.object();
    if (rootObj.value("status").toString() != "ok") return;

    QJsonArray articlesArray = rootObj.value("articles").toArray();

    qDebug() << "Отримано додаткових новин з API:" << articlesArray.count();

    if (articlesArray.isEmpty()) {
        qDebug() << "Новини за цим запитом закінчилися!";
        return;
    }

    QList<Article> newFilteredArticles;
    QStringList newSourceList = m_sourceList;

    for (const QJsonValue &val : articlesArray) {
        QJsonObject obj = val.toObject();
        Article article;

        article.title = obj.value("title").toString();
        article.description = obj.value("description").toString();
        article.url = obj.value("url").toString();
        article.imageUrl = obj.value("urlToImage").toString();

        QString rawDate = obj.value("publishedAt").toString();
        article.publishedAt = rawDate.replace("T", " ").replace("Z", "");

        QJsonObject sourceObj = obj.value("source").toObject();
        article.sourceName = sourceObj.value("name").toString();
        article.content = obj.value("content").toString();

        m_allArticles.append(article);

        if (m_currentSourceFilter == "All sources" ||
            m_currentSourceFilter == "Усі джерела" ||
            article.sourceName == m_currentSourceFilter) {

            newFilteredArticles.append(article);
        }

        if (!newSourceList.contains(article.sourceName) && !article.sourceName.isEmpty()) {
            newSourceList.append(article.sourceName);
        }
    }

    if (!newFilteredArticles.isEmpty()) {
        int startIndex = m_articles.count();
        int endIndex = startIndex + newFilteredArticles.count() - 1;

        beginInsertRows(QModelIndex(), startIndex, endIndex);
        m_articles.append(newFilteredArticles);
        endInsertRows();
    }

    if (m_sourceList.count() != newSourceList.count()) {
        m_sourceList = newSourceList;
        emit sourceListChanged();
    }
}