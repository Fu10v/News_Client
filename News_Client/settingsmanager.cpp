#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    // QSettings автоматично підхопить імена
}

void SettingsManager::save(const QString &key, const QVariant &value)
{
    m_settings.setValue(key, value);
    m_settings.sync();
}

QVariant SettingsManager::load(const QString &key, const QVariant &defaultValue)
{
    return m_settings.value(key, defaultValue);
}