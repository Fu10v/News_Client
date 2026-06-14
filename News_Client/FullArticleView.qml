import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebView

Rectangle {
    id: root
    color: palette.window

    property string articleTitle: "Заголовок статті"
    property string articleContent: "Тут буде повний текст..."
    property string articleDate: "Сьогодні"
    property string articleSource: "Джерело новин"
    property string articleImageUrl: ""
    property string articleUrl: ""

    TextEdit {
        id: clipboardHelper
        visible: false
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ==========================================
        // 1. ВЕРХНЯ ПАНЕЛЬ ІНСТРУМЕНТІВ
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: palette.base

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: palette.text
                opacity: 0.1
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 15

                Button {
                    text: appWindow.currentLang === "en" ? "← Back to news" : "← Назад до новин"
                    onClicked: root.StackView.view.pop()

                    contentItem: Text {
                        text: parent.text
                        color: palette.text
                        font.pixelSize: 15
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        implicitWidth: 150
                        implicitHeight: 36
                        color: parent.hovered ? palette.button : "transparent"
                        radius: 4
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    // Перевіряємо при запуску, чи стаття вже у базі
                    property bool isSaved: dbManager.isArticleSaved(root.articleUrl)

                    text: isSaved ? "✔️ Saved" : "⭐ Save Article"

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        implicitWidth: 160
                        implicitHeight: 36
                        color: parent.isSaved ? theme.accent : palette.highlight // Змінюємо колір, якщо збережено
                        radius: 4
                    }

                    onClicked: {
                        if (isSaved) {
                            // Якщо збережено - видаляємо
                            dbManager.deleteArticle(root.articleUrl)
                            isSaved = false
                        } else {
                            // Якщо ні - зберігаємо
                            dbManager.saveArticle(
                                root.articleTitle,
                                root.articleContent, // Опис або контент
                                root.articleDate,
                                root.articleSource,
                                root.articleImageUrl,
                                root.articleUrl,
                                root.articleContent
                            )
                            isSaved = true
                            appWindow.showToast(appWindow.currentLang === "en" ? "Article saved!" : "Статтю збережено!")
                        }
                    }
                }

                Button {
                    text: appWindow.currentLang === "en" ? "🔗 Copy Link" : "🔗 Копіювати"

                    contentItem: Text {
                        text: parent.text
                        color: theme.textPrimary
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        implicitWidth: 140
                        implicitHeight: 36
                        color: parent.pressed ? theme.border : "transparent"
                        border.color: theme.border
                        border.width: 1
                        radius: 4
                    }

                    onClicked: {
                        clipboardHelper.text = root.articleUrl
                        clipboardHelper.selectAll()
                        clipboardHelper.copy()

                        // ВИКЛИКАЄМО ЧЕРЕЗ appWindow
                        appWindow.showToast(appWindow.currentLang === "en" ? "Link copied to clipboard!" : "Посилання скопійовано!")
                    }
                }
            }
        }

        // ==========================================
        // 2. ОБЛАСТЬ КОНТЕНТУ (ПРОКРУТКА)
        // ==========================================
        WebView {
            id: webView
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Переходимо за посиланням
            url: root.articleUrl !== "" ? root.articleUrl : "about:blank"

            // Заглушка, якщо посилання немає (хоча для реальних новин воно зазвичай є)
            Rectangle {
                anchors.fill: parent
                color: palette.window
                visible: root.articleUrl === ""

                Text {
                    anchors.centerIn: parent
                    text: "Посилання на статтю недоступне"
                    color: palette.text
                    font.pixelSize: 18
                }
            }
        }
    }
}
