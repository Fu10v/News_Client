#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QVariantMap>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    setupDatabase();
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

void DatabaseManager::setupDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");

    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    m_db.setDatabaseName(dataDir + "/news_database.sqlite");

    if (!m_db.open()) {
        qWarning() << "Помилка відкриття БД:" << m_db.lastError().text();
        return;
    }

    QSqlQuery query;
    QString createTableQuery = R"(
        CREATE TABLE IF NOT EXISTS saved_articles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            date TEXT,
            source TEXT,
            image_url TEXT,
            url TEXT UNIQUE,
            content TEXT
        )
    )";

    if (!query.exec(createTableQuery)) {
        qWarning() << "Помилка створення таблиці:" << query.lastError().text();
    } else {
        qDebug() << "База даних успішно ініціалізована за адресою:" << m_db.databaseName();
    }
}

bool DatabaseManager::saveArticle(const QString &title, const QString &description,
                                  const QString &date, const QString &source,
                                  const QString &imageUrl, const QString &url,
                                  const QString &content)
{
    QSqlQuery query;
    query.prepare("INSERT OR IGNORE INTO saved_articles (title, description, date, source, image_url, url, content) "
                  "VALUES (:title, :description, :date, :source, :image_url, :url, :content)");

    query.bindValue(":title", title);
    query.bindValue(":description", description);
    query.bindValue(":date", date);
    query.bindValue(":source", source);
    query.bindValue(":image_url", imageUrl);
    query.bindValue(":url", url);
    query.bindValue(":content", content);

    if (!query.exec()) {
        qWarning() << "Помилка збереження статті:" << query.lastError().text();
        return false;
    }

    emit savedArticlesChanged();
    return true;
}

bool DatabaseManager::deleteArticle(const QString &url)
{
    QSqlQuery query;
    query.prepare("DELETE FROM saved_articles WHERE url = :url");
    query.bindValue(":url", url);

    bool success = query.exec();
    if (success) {
        emit savedArticlesChanged();
    }
    return success;
}

bool DatabaseManager::isArticleSaved(const QString &url)
{
    QSqlQuery query;
    query.prepare("SELECT id FROM saved_articles WHERE url = :url");
    query.bindValue(":url", url);
    if (query.exec() && query.next()) {
        return true;
    }
    return false;
}

QVariantList DatabaseManager::getSavedArticles(const QString &searchTerm)
{
    QVariantList list;
    QSqlQuery query;

    if (searchTerm.isEmpty()) {
        query.prepare("SELECT * FROM saved_articles ORDER BY id DESC");
    } else {
        query.prepare("SELECT * FROM saved_articles WHERE title LIKE :term OR source LIKE :term ORDER BY id DESC");
        query.bindValue(":term", "%" + searchTerm + "%"); 
    }

    if (!query.exec()) {
        qWarning() << "Помилка завантаження збережених статей:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        QVariantMap map;
        map["titleText"] = query.value("title").toString();
        map["descriptionText"] = query.value("description").toString();
        map["dateText"] = query.value("date").toString();
        map["sourceText"] = query.value("source").toString();
        map["imageUrl"] = query.value("image_url").toString();
        map["url"] = query.value("url").toString();
        map["contentText"] = query.value("content").toString();
        list.append(map);
    }
    return list;
}

QString DatabaseManager::exportToCSV()
{
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString fileName = docPath + "/SavedNews_" + QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") + ".csv";

    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Не вдалося створити файл для експорту";
        return "";
    }

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << "Source;Date;Title;URL\n";

    QSqlQuery query("SELECT source, date, title, url FROM saved_articles ORDER BY id DESC");
    while (query.next()) {
        QString source = query.value("source").toString().replace(";", ",").replace("\n", " ");
        QString date = query.value("date").toString().replace(";", ",").replace("\n", " ");
        QString title = query.value("title").toString().replace(";", ",").replace("\n", " ");
        QString url = query.value("url").toString();

        out << source << ";" << date << ";" << title << ";" << url << "\n";
    }

    file.close();
    return fileName;
}

