#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>
#include <QString>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    // Зберігає статтю в базу даних
    Q_INVOKABLE bool saveArticle(const QString &title, const QString &description,
                                 const QString &date, const QString &source,
                                 const QString &imageUrl, const QString &url,
                                 const QString &content);

    // Видаляє статтю з бази (пошук за унікальним URL)
    Q_INVOKABLE bool deleteArticle(const QString &url);

    // Повертає список усіх збережених статей для QML
    Q_INVOKABLE QVariantList getSavedArticles(const QString &searchTerm = "");

    // Перевіряє, чи вже збережена стаття з таким посиланням
    Q_INVOKABLE bool isArticleSaved(const QString &url);

    Q_INVOKABLE QString exportToCSV();

signals:
    // Сигнал, який спрацьовуватиме при зміні бази даних
    void savedArticlesChanged();

private:
    QSqlDatabase m_db;
    void setupDatabase(); // Внутрішній метод для створення таблиці
};

#endif
