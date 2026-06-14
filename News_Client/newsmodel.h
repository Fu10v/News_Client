#ifndef NEWSMODEL_H
#define NEWSMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QList>
#include <QByteArray>

// Структура для зберігання однієї новини
struct Article {
    QString title;
    QString description;
    QString url;
    QString imageUrl;
    QString publishedAt;
    QString sourceName;
    QString content;
};

class NewsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList sourceList READ sourceList NOTIFY sourceListChanged)

public:
    // Ролі (імена змінних) для передачі даних у QML
    enum ArticleRoles {
        TitleRole = Qt::UserRole + 1,
        DescriptionRole,
        UrlRole,
        ImageUrlRole,
        DateRole,
        SourceRole,
        ContentRole // <-- ДОДАЙ ЦЮ РОЛЬ ДЛЯ ТЕКСТУ СТАТТІ
    };

    explicit NewsModel(QObject *parent = nullptr);

    // Обов'язкові методи для роботи моделі списку у Qt
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    QStringList sourceList() const { return m_sourceList; }

public slots:
    // Слот, який прийматиме дані від NetworkManager
    void parseJson(const QByteArray &jsonData);
    void applyFilters(int sortIndex, const QString &sourceFilter);
    void appendJson(const QByteArray &jsonData);

signals:
    void sourceListChanged();

private:
    QList<Article> m_allArticles; // Оригінальний список (ВСІ завантажені новини)
    QList<Article> m_articles;    // Відфільтрований список (те, що бачить користувач)
    QStringList m_sourceList;     // Динамічний список унікальних джерел
    int m_currentSortIndex = 0;
    QString m_currentSourceFilter = "All sources";
};

#endif // NEWSMODEL_H
