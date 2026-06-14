import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: ListView.view ? ListView.view.width : 0
    height: isFeatured ? 350 : 120
    radius: 8
    clip: true

    property string titleText: ""
    property string descriptionText: ""
    property string imageUrl: ""
    property string dateText: ""
    property bool isFeatured: false

    // Властивості для теми
    property var cardTheme
    property bool isDark: false

    // Декларативне визначення кольору (залежить від теми та наведення миші)
    color: {
        if (isFeatured) return "#222222"; // Головна новина завжди має темний фон
        return hoverArea.containsMouse ? (isDark ? "#2A2A2A" : "#F9F9F9") : cardTheme.surface
    }
    border.color: cardTheme.border

    signal clicked()

    // Звичайна новина
    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15
        visible: !root.isFeatured

        Rectangle {
            Layout.preferredWidth: 140
            Layout.fillHeight: true
            color: isDark ? "#333333" : "#EEEEEE"
            radius: 6
            clip: true // Обрізає краї картинки під радіус 6

            // Додаємо компонент зображення
            Image {
                anchors.fill: parent
                source: root.imageUrl
                fillMode: Image.PreserveAspectCrop // Масштабує фото так, щоб воно заповнило блок без спотворень
                asynchronous: true // ВАЖЛИВО! Дозволяє QML завантажувати фото без зависання інтерфейсу
                visible: status === Image.Ready // Показує фото тільки якщо посилання не порожнє
            }

            // Текст-заглушка тепер з'являється тільки якщо фото немає
            Text {
                anchors.centerIn: parent;
                text: "Photo";
                color: isDark ? "#888888" : "#999999"
                visible: root.imageUrl === ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            Label {
                Layout.fillWidth: true
                text: root.titleText
                font.pixelSize: 16
                font.bold: true
                color: cardTheme.textPrimary
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.descriptionText
                font.pixelSize: 14
                color: cardTheme.textSecondary
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 3
                verticalAlignment: Text.AlignTop
            }

            Label {
                text: root.dateText
                font.pixelSize: 12
                color: cardTheme.textSecondary
            }
        }
    }

    // Головна новина (фото на фоні)
    Rectangle {
        anchors.fill: parent
        visible: root.isFeatured
        color: "#222222" // Заглушка під картинку

        Image {
            anchors.fill: parent
            source: root.imageUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#E6000000" } // Сильніший градієнт для читабельності
            }
        }

        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: root.titleText
                color: "white" // Завжди білий на фоні картинки
                font.pixelSize: 26
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            Label {
                text: root.dateText
                color: "#DDDDDD"
                font.pixelSize: 14
            }
        }
    }

    MouseArea {
        id: hoverArea // Додали ID для відстеження стану
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        // Прибрали onEntered та onExited, тепер QML сам керує кольором
    }
}
