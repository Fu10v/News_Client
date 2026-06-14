import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    title: "News Client"

    // Глобальний стан теми
    property bool isDarkMode: true
    property bool isGridView: false
    property string currentLang: "en"

    function showToast(msg) {
        toast.show(msg)
    }

    Component.onCompleted: {
        appWindow.currentLang = settingsManager.load("language", "en")

        // Завантажуємо число (0 за замовчуванням)
        let savedTheme = settingsManager.load("darkMode", 0)
        console.log("Завантажена тема (число):", savedTheme)

        // Якщо завантажили 1 (або текст "1") - вмикаємо темну
        appWindow.isDarkMode = (savedTheme === 1 || savedTheme === "1")
    }


    // Централізована палітра кольорів
    QtObject {
        id: theme
        property color background: appWindow.isDarkMode ? "#1A1A1A" : "#F4F4F4"
        property color surface: appWindow.isDarkMode ? "#242424" : "white"
        property color textPrimary: appWindow.isDarkMode ? "#FFFFFF" : "black"
        property color textSecondary: appWindow.isDarkMode ? "#AAAAAA" : "gray"
        property color border: appWindow.isDarkMode ? "#333333" : "#E0E0E0"
        property color tagBackground: appWindow.isDarkMode ? "#333333" : "#E8E8E8"
        property color accent: appWindow.isDarkMode ? "#4CAF50" : "#2E7D32" // Акцентний колір (наприклад, для кнопок)
    }

    QtObject {
        id: t
        // Головні
        property string appTitle: currentLang === "en" ? "NEWS CLIENT" : "НОВИННИЙ КЛІЄНТ"
        property string searchPlaceholder: currentLang === "en" ? "Search news..." : "Пошук новин..."
        property string themeToggle: appWindow.isDarkMode
                                     ? (currentLang === "en" ? "🌙 Dark" : "🌙 Темна")
                                     : (currentLang === "en" ? "☀️ Light" : "☀️ Світла")
        // Теги
        property var tagsList: currentLang === "en"
                               ? ["General", "Entertainment", "Science", "Technology", "Business", "Sports", "Health"]
                               : ["Головне", "Технології", "Бізнес", "Спорт", "Здоров'я"]
        property var apiCategories: ["general", "entertainment", "science", "technology", "business", "sports", "health"]
        // Збережене
        property string savedTitle: currentLang === "en" ? "Saved Articles" : "Збережені статті"
        property string savedSub: currentLang === "en" ? "Available offline" : "Доступні офлайн"
        // Фільтри
        property string filterTitle: currentLang === "en" ? "Search Filters" : "Фільтри пошуку"
        property var filterSort: currentLang === "en"
                                 ? ["Newest first", "Oldest first", "Relevance"]
                                 : ["Нові спочатку", "Старі спочатку", "За релевантністю"]
        property string filterSources: currentLang === "en" ? "Filter by Source:" : "Фільтр джерел:"
        property string srcAll: currentLang === "en" ? "All sources" : "Усі джерела"
        property string srcBBC: "BBC News"
        property string srcCNN: "CNN"
        property string applyBtn: currentLang === "en" ? "Apply Filters" : "Застосувати"
        property string searchBtn: currentLang === "en" ? "Search" : "Знайти"
    }

    // ==========================================
    // ПРИМУСОВЕ ПЕРЕВИЗНАЧЕННЯ СИСТЕМНОЇ ПАЛІТРИ
    // Це відключить вплив теми Windows на стандартні компоненти
    // ==========================================
    palette.window: theme.background
    palette.windowText: theme.textPrimary
    palette.base: theme.surface
    palette.text: theme.textPrimary
    palette.button: theme.tagBackground
    palette.buttonText: theme.textPrimary
    palette.highlight: theme.accent
    palette.highlightedText: "#FFFFFF"

    color: theme.background

    StackView {
            id: stackView
            anchors.fill: parent
            initialItem: mainDashboard
        }

        Component {
            id: mainDashboard

            ColumnLayout {
                spacing: 0

                // 1. ВЕРХНЯ ПАНЕЛЬ
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: theme.surface

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 15

                        Label {
                            text: t.appTitle
                            font.pixelSize: 24
                            font.bold: true
                            color: theme.textPrimary
                        }

                        Item { Layout.fillWidth: true } // Розпірка

                        TextField {
                            id: searchInput
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 36
                            placeholderText: t.searchPlaceholder
                            font.pixelSize: 14
                            color: theme.textPrimary
                            placeholderTextColor: theme.textSecondary
                            palette.text: theme.textPrimary
                            palette.highlight: theme.accent
                            palette.highlightedText: "#FFFFFF"

                            background: Rectangle {
                                color: appWindow.isDarkMode ? "#1E1E1E" : "#F4F4F4"
                                border.color: theme.border
                                radius: 4
                            }

                            // Запуск пошуку при натисканні Enter на клавіатурі
                            onAccepted: {
                                let activeCategory = t.apiCategories[tagPanel.activeTagIndex]
                                networkManager.fetchNews(searchInput.text, activeCategory, appWindow.currentLang)
                                filterCombo.currentIndex = 0
                            }
                        }

                        // НОВА КНОПКА ПОШУКУ
                        Button {
                            text: t.searchBtn
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 13
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                implicitWidth: 80
                                implicitHeight: 36
                                color: parent.pressed ? Qt.darker(theme.accent, 1.2) : theme.accent
                                radius: 4
                            }

                            // Запуск пошуку при кліку мишкою
                            onClicked: {
                                let activeCategory = t.apiCategories[tagPanel.activeTagIndex]
                                networkManager.fetchNews(searchInput.text, activeCategory, appWindow.currentLang)
                                filterCombo.currentIndex = 0
                            }
                        }

                        Button {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            text: appWindow.isGridView ? "☰" : "⊞" // Змінює іконку

                            contentItem: Text {
                                text: parent.text
                                color: theme.textPrimary
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: theme.border
                                radius: 4
                            }
                            onClicked: appWindow.isGridView = !appWindow.isGridView
                        }

                        // КНОПКА МОВИ
                        /*
                        Button {
                            text: appWindow.currentLang === "en" ? "🇺🇦 UA" : "🇬🇧 EN"
                            contentItem: Text {
                                text: parent.text
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }
                            background: Rectangle {
                                implicitWidth: 60
                                implicitHeight: 36
                                color: parent.hovered ? theme.tagBackground : "transparent"
                                border.color: theme.border
                                radius: 18
                            }
                            onClicked: appWindow.currentLang = appWindow.currentLang === "en" ? "uk" : "en"
                        }
                        */

                        // КНОПКА ТЕМИ
                        Button {
                            text: t.themeToggle
                            contentItem: Text {
                                text: parent.text
                                color: theme.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                            }
                            background: Rectangle {
                                implicitWidth: 100
                                implicitHeight: 36
                                color: parent.hovered ? theme.tagBackground : "transparent"
                                border.color: theme.border
                                radius: 18
                            }
                            onClicked: {
                                appWindow.isDarkMode = !appWindow.isDarkMode

                                // Зберігаємо як число: 1 якщо темна, 0 якщо світла
                                settingsManager.save("darkMode", appWindow.isDarkMode ? 1 : 0)
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: theme.border }

                // 2. ПАНЕЛЬ ТЕГІВ
                Rectangle {
                    id: tagPanel // <--- Додаємо чіткий ID для цієї панелі
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: theme.background

                    // Наша змінна тепер безпечно живе тут
                    property int activeTagIndex: 0

                    ListView {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        orientation: ListView.Horizontal
                        spacing: 10
                        model: t.tagsList

                        delegate: Rectangle {
                            width: tagText.width + 30
                            height: 30
                            anchors.verticalCenter: parent.verticalCenter

                            // Звертаємося безпосередньо через tagPanel (надійно)
                            color: tagPanel.activeTagIndex === index ? theme.accent : theme.tagBackground
                            radius: 15

                            Text {
                                id: tagText
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 13
                                // Звертаємося безпосередньо через tagPanel
                                color: tagPanel.activeTagIndex === index ? "#FFFFFF" : theme.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    // Оновлюємо індекс суворо через ID
                                    tagPanel.activeTagIndex = index

                                    // Відправляємо запит з правильною категорією
                                    networkManager.fetchNews(searchInput.text, t.apiCategories[index], appWindow.currentLang)
                                }
                            }
                        }
                    }
                }

                // 3. ГОЛОВНА ОБЛАСТЬ
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    spacing: 20

                    // Ліва колонка (Збережене)
                    Rectangle {
                        Layout.preferredWidth: 280
                        Layout.fillHeight: true
                        color: theme.surface
                        border.color: theme.border
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            Label { text: t.savedTitle; font.pixelSize: 18; font.bold: true; color: theme.textPrimary }

                            // НОВЕ: Поле пошуку по базі даних
                            TextField {
                                id: savedSearchInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                placeholderText: appWindow.currentLang === "en" ? "Search in saved..." : "Пошук у збереженому..."
                                color: theme.textPrimary
                                placeholderTextColor: theme.textSecondary
                                palette.text: theme.textPrimary
                                palette.highlight: theme.accent
                                palette.highlightedText: "#FFFFFF"
                                font.pixelSize: 13
                                background: Rectangle {
                                    color: appWindow.isDarkMode ? "#2D2D2D" : "#EAEAEA"
                                    radius: 4
                                }

                                // Щойно текст змінюється - відправляємо SQL запит (динамічний пошук)
                                onTextEdited: {
                                    savedListView.model = dbManager.getSavedArticles(savedSearchInput.text)
                                }
                            }

                            // НОВЕ: Кнопка експорту
                            Button {
                                id: exportBtn
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                text: appWindow.currentLang === "en" ? "📥 Export to CSV" : "📥 Експорт у CSV"

                                contentItem: Text {
                                    text: parent.text
                                    color: theme.textPrimary
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: parent.pressed ? theme.border : "transparent"
                                    border.color: theme.border
                                    radius: 4
                                }

                                onClicked: {
                                    let path = dbManager.exportToCSV()
                                    if (path !== "") {
                                        // Показуємо успішне повідомлення
                                        toast.show(appWindow.currentLang === "en" ? "Saved to Documents" : "Збережено в Документи")
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: theme.border
                            }

                            // СПИСОК ЗБЕРЕЖЕНИХ СТАТЕЙ
                            ListView {
                                id: savedListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 10

                                // Завантажуємо статті при старті
                                Component.onCompleted: model = dbManager.getSavedArticles("")

                                // Автоматично оновлюємо список, коли С++ посилає сигнал
                                Connections {
                                    target: dbManager
                                    function onSavedArticlesChanged() {
                                        savedListView.model = dbManager.getSavedArticles(savedSearchInput.text)
                                    }
                                }

                                delegate: Rectangle {
                                    width: ListView.view ? ListView.view.width : 0
                                    height: 70
                                    color: savedMouseArea.containsMouse ? theme.tagBackground : "transparent"
                                    radius: 6

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 10

                                        // Міні-фото
                                        Rectangle {
                                            Layout.preferredWidth: 54
                                            Layout.preferredHeight: 54
                                            color: theme.tagBackground
                                            radius: 4
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                source: modelData.imageUrl
                                                fillMode: Image.PreserveAspectCrop
                                                asynchronous: true
                                                visible: status === Image.Ready
                                            }
                                        }

                                        // Заголовок
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.titleText
                                            color: theme.textPrimary
                                            font.pixelSize: 13
                                            font.bold: true
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 3 // Максимум 3 рядки тексту
                                        }
                                    }

                                    // Натискання на збережену статтю відкриває її на весь екран
                                    MouseArea {
                                        id: savedMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            stackView.push("FullArticleView.qml", {
                                                "articleTitle": modelData.titleText,
                                                "articleContent": modelData.contentText,
                                                "articleDate": modelData.dateText,
                                                "articleSource": modelData.sourceText,
                                                "articleImageUrl": modelData.imageUrl,
                                                "articleUrl": modelData.url
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Центральна колонка (Новини)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        ListView {
                            id: newsListView
                            anchors.fill: parent
                            spacing: 15
                            clip: true
                            model: newsModel
                            visible: !appWindow.isGridView

                            onMovementEnded: {
                                // atYEnd - це вбудована змінна, яка стає true, коли список докрутили до кінця
                                if (atYEnd) {
                                    // Показуємо користувачу, що щось відбувається (опціонально)
                                    appWindow.showToast(appWindow.currentLang === "en" ? "Loading more news..." : "Завантаження новин...")

                                    // Викликаємо наш новий C++ метод
                                    networkManager.loadMoreNews()
                                }
                            }

                            delegate: NewsCard {
                                isFeatured: index === 0
                                titleText: model.titleText
                                descriptionText: model.descriptionText
                                dateText: model.dateText
                                imageUrl: model.imageUrl
                                cardTheme: theme
                                isDark: appWindow.isDarkMode

                                onClicked: {
                                    stackView.push("FullArticleView.qml", {
                                        "articleTitle": model.titleText,
                                        "articleContent": model.contentText ? model.contentText : model.descriptionText,
                                        "articleDate": model.dateText,
                                        "articleSource": model.sourceText,
                                        "articleImageUrl": model.imageUrl,
                                        "articleUrl": model.url
                                    });
                                }
                            }
                        }

                        GridView {
                            id: newsGridView
                            anchors.fill: parent
                            clip: true
                            cellWidth: width / 2 // Дві колонки
                            cellHeight: 280      // Висота плитки
                            model: newsModel

                            // Показуємо тільки якщо обрано режим сітки
                            visible: appWindow.isGridView

                            onMovementEnded: {
                                // atYEnd - це вбудована змінна, яка стає true, коли список докрутили до кінця
                                if (atYEnd) {
                                    // Показуємо користувачу, що щось відбувається (опціонально)
                                    appWindow.showToast(appWindow.currentLang === "en" ? "Loading more news..." : "Завантаження новин...")

                                    // Викликаємо наш новий C++ метод
                                    networkManager.loadMoreNews()
                                }
                            }

                            delegate: Rectangle {
                                width: newsGridView.cellWidth - 15
                                height: newsGridView.cellHeight - 15
                                color: theme.surface
                                border.color: theme.border
                                radius: 8
                                clip: true

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 140
                                        color: theme.tagBackground
                                        Image {
                                            anchors.fill: parent
                                            source: model.imageUrl !== "" ? model.imageUrl : "qrc:/placeholder.png"
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.margins: 12
                                        spacing: 5

                                        Text {
                                            Layout.fillWidth: true
                                            text: model.titleText
                                            color: theme.textPrimary
                                            font.pixelSize: 14
                                            font.bold: true
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                            maximumLineCount: 3
                                        }
                                        Item { Layout.fillHeight: true } // Розпірка
                                        Text {
                                            text: model.sourceText + " • " + model.dateText.substring(0, 10)
                                            color: theme.textSecondary
                                            font.pixelSize: 11
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        stackView.push("FullArticleView.qml", {
                                            "articleTitle": model.titleText,
                                            "articleContent": model.contentText ? model.contentText : model.descriptionText,
                                            "articleDate": model.dateText,
                                            "articleSource": model.sourceText,
                                            "articleImageUrl": model.imageUrl,
                                            "articleUrl": model.url
                                        });
                                    }
                                }
                            }
                        }
                    }

                    // Права колонка (Фільтри)
                    Rectangle {
                        Layout.preferredWidth: 320
                        Layout.fillHeight: true
                        color: theme.surface
                        border.color: theme.border
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            Label { text: t.filterTitle; font.pixelSize: 18; font.bold: true; color: theme.textPrimary }

                            ComboBox {
                                id: filterCombo
                                Layout.fillWidth: true
                                model: t.filterSort

                                contentItem: Text {
                                    leftPadding: 10
                                    rightPadding: 10
                                    text: filterCombo.displayText
                                    font: filterCombo.font
                                    color: theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                                background: Rectangle {
                                    implicitHeight: 40
                                    color: appWindow.isDarkMode ? "#1E1E1E" : "#F4F4F4"
                                    border.color: theme.border
                                    radius: 4
                                }
                                delegate: ItemDelegate {
                                    width: filterCombo.width
                                    contentItem: Text {
                                        text: modelData
                                        color: highlighted ? "#FFFFFF" : theme.textPrimary
                                        font: filterCombo.font
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: highlighted ? theme.accent : theme.surface
                                    }
                                    highlighted: filterCombo.highlightedIndex === index
                                }
                                popup: Popup {
                                    y: filterCombo.height - 1
                                    width: filterCombo.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: filterCombo.popup.visible ? filterCombo.delegateModel : null
                                        currentIndex: filterCombo.highlightedIndex
                                    }
                                    background: Rectangle {
                                        color: theme.surface
                                        border.color: theme.border
                                        radius: 4
                                    }
                                }
                            }

                            Label { text: t.filterSources; font.bold: true; Layout.topMargin: 10; color: theme.textPrimary }

                            ComboBox {
                                id: sourceCombo
                                Layout.fillWidth: true

                                // Підключаємо динамічний список з C++
                                model: newsModel.sourceList

                                contentItem: Text {
                                    leftPadding: 10
                                    rightPadding: 10
                                    text: sourceCombo.displayText
                                    font: sourceCombo.font
                                    color: theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                                background: Rectangle {
                                    implicitHeight: 40
                                    color: appWindow.isDarkMode ? "#1E1E1E" : "#F4F4F4"
                                    border.color: theme.border
                                    radius: 4
                                }
                                delegate: ItemDelegate {
                                    width: sourceCombo.width
                                    contentItem: Text {
                                        text: modelData // Тут modelData - це назва джерела
                                        color: highlighted ? "#FFFFFF" : theme.textPrimary
                                        font: sourceCombo.font
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: highlighted ? theme.accent : theme.surface
                                    }
                                    highlighted: sourceCombo.highlightedIndex === index
                                }
                                popup: Popup {
                                    y: sourceCombo.height - 1
                                    width: sourceCombo.width
                                    implicitHeight: contentItem.implicitHeight > 250 ? 250 : contentItem.implicitHeight // Обмежуємо висоту меню
                                    padding: 1
                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: sourceCombo.popup.visible ? sourceCombo.delegateModel : null
                                        currentIndex: sourceCombo.highlightedIndex
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    }
                                    background: Rectangle {
                                        color: theme.surface
                                        border.color: theme.border
                                        radius: 4
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Button {
                                Layout.fillWidth: true
                                text: t.applyBtn
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                background: Rectangle {
                                    implicitHeight: 40
                                    color: parent.pressed ? Qt.darker(theme.accent, 1.2) : theme.accent
                                    radius: 4
                                }
                                onClicked: {
                                    // Викликаємо наш новий C++ метод локального сортування!
                                    // Передаємо індекс сортування (0, 1 або 2) та текст обраного джерела
                                    newsModel.applyFilters(filterCombo.currentIndex, sourceCombo.currentText)
                                }
                            }
                        }
                    }
                }
            }
        }

        Popup {
            id: toast

            // Центруємо по горизонталі, але тепер показуємо ЗВЕРХУ (відступ 20 пікселів)
            x: (appWindow.width - width) / 2
            y: 20

            width: toastText.width + 60
            height: 45

            modal: false
            focus: false
            closePolicy: Popup.NoAutoClose

            background: Rectangle {
                color: appWindow.isDarkMode ? "#E0E0E0" : "#333333"
                radius: 22
                // Додаємо легку тінь для об'єму (опціонально)
                border.color: appWindow.isDarkMode ? "#FFFFFF" : "#000000"
                border.width: 1
            }

            Text {
                id: toastText
                anchors.centerIn: parent
                color: appWindow.isDarkMode ? "#121212" : "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
            }

            Timer {
                id: toastTimer
                interval: 2500
                onTriggered: toast.close()
            }

            // Анімація: повідомлення "випадає" зверху і плавно зникає туди ж
            enter: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 300 }
                    NumberAnimation { property: "y"; from: -50; to: 20; duration: 300; easing.type: Easing.OutBack }
                }
            }
            exit: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 300 }
                    NumberAnimation { property: "y"; from: 20; to: -50; duration: 300; easing.type: Easing.InBack }
                }
            }

            function show(msg) {
                toastText.text = msg
                toast.open()
                toastTimer.restart()
            }
        }
    }
