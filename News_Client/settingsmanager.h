#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QString>

class SettingsManager : public QObject
{
    Q_OBJECT
public:
    explicit SettingsManager(QObject *parent = nullptr);

    // Метод для збереження (наприклад: save("language", "ua"))
    Q_INVOKABLE void save(const QString &key, const QVariant &value);

    // Метод для завантаження (якщо ключа немає, поверне defaultValue)
    Q_INVOKABLE QVariant load(const QString &key, const QVariant &defaultValue = QVariant());

private:
    QSettings m_settings;
};

#endif