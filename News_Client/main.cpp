#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include "NetworkManager.h"
#include "NewsModel.h"
#include "DatabaseManager.h"
#include "SettingsManager.h"

// Головна функція — точка входу в програму
int main(int argc, char *argv[])
{
// Підтримка масштабування для екранів з високою роздільною здатністю (актуально для старих версій Qt)
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // Встановлення метаданих програми (використовується класом QSettings для запису в реєстр)
    QCoreApplication::setOrganizationName("KHNURE");
    QCoreApplication::setOrganizationDomain("nure.ua");
    QCoreApplication::setApplicationName("NewsClient");

    // Ініціалізація модуля WebView перед створенням графічного застосунку
    QtWebView::initialize();

    // Створення головного об'єкта графічного застосунку (керує циклом подій)
    QGuiApplication app(argc, argv);

    // Встановлення базового стилю для елементів інтерфейсу
    QQuickStyle::setStyle("Basic");

    // 1. Ініціалізуємо об'єкти прикладної логіки
    NetworkManager networkManager;   // Об'єкт мережевої взаємодії
    NewsModel newsModel;             // Об'єкт моделі даних (список новин)

    DatabaseManager dbManager;       // Об'єкт керування локальним архівом
    SettingsManager settingsManager; // Об'єкт конфігурації (теми, мови тощо)

    // 2. Зв'язуємо сигнал NetworkManager зі слотом NewsModel.
    // Коли мережа завантажить байти, вони автоматично передадуться у парсер моделі.
    QObject::connect(&networkManager, &NetworkManager::dataReady,
                     &newsModel, &NewsModel::parseJson);
    
    // Підключення для механізму нескінченної прокрутки (довантаження нових сторінок)
    QObject::connect(&networkManager, &NetworkManager::moreDataReady, 
                     &newsModel, &NewsModel::appendJson);

    // Створення декларативного рушія QML
    QQmlApplicationEngine engine;

    // 3. Реєструємо C++ екземпляри у кореневому контексті QML
    // Це дозволяє візуальним компонентам напряму викликати методи цих класів
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("newsModel", &newsModel);             // Експорт моделі
    context->setContextProperty("networkManager", &networkManager);   // Експорт мережевого модуля
    context->setContextProperty("dbManager", &dbManager);             // Експорт бази даних
    context->setContextProperty("settingsManager", &settingsManager); // Експорт налаштувань

    // Шлях до стартового файлу інтерфейсу
    const QUrl url(QStringLiteral("qrc:/qt/qml/News_Client/Main.qml")); 
    
    // Перевірка успішності створення дерева QML-об'єктів
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1); // Завершення програми при помилці інтерфейсу
                     }, Qt::QueuedConnection);

    // Завантаження інтерфейсу у пам'ять
    engine.load(url);

    // 4. Запускаємо первинне завантаження новин одразу після старту програми (порожні рядки = пошук без фільтрів)
    networkManager.fetchNews("", "");

    // Запуск головного циклу обробки подій ОС
    return app.exec();
}
