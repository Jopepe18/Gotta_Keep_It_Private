import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 500
    height: 720
    title: "Edit password" // Changed
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#1E2634"

    // Aliases για να περνάμε τα δεδομένα από το PasswordsPage
    property int itemId: -1
    property alias titleText: titleInput.text
    property alias usernameText: usernameInput.text
    property alias passwordText: passwordInput.text
    property alias websiteText: websiteInput.text
    property alias noteText: noteInput.text

    signal updateRequested(int id, string title, string username, string password, string website, string note)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        Label {
            text: "Edit password" // Changed
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Title
        ColumnLayout {
            spacing: 5
            Label { text: "Title"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField {
                id: titleInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
            }
        }

        // Username
        ColumnLayout {
            spacing: 5
            Label { text: "Username"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField {
                id: usernameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
            }
        }

        // Password
        ColumnLayout {
            spacing: 5
            Label { text: "Password"; color: "#B5B5B5"; font.pixelSize: 14 }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#303946"
                radius: 10
                border.color: "white"
                border.width: 1
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    TextField {
                        id: passwordInput
                        Layout.fillWidth: true
                        font.pixelSize: 16
                        color: "white"
                        echoMode: showPassBtn.checked ? TextInput.Normal : TextInput.Password
                        background: Rectangle { color: "transparent" }
                    }
                    Button {
                        id: showPassBtn
                        checkable: true
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        background: Rectangle { color: "transparent" }
                        contentItem: Image {
                            source: showPassBtn.checked ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }
        }

        // Website
        ColumnLayout {
            spacing: 5
            Label { text: "Website"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField {
                id: websiteInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
            }
        }

        // Note
        ColumnLayout {
            spacing: 5
            Label { text: "Note"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextArea {
                id: noteInput
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
            }
        }

        Item { Layout.fillHeight: true }

        // Buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30

            Button {
                text: "Cancel"
                font.pixelSize: 16
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "#F76262"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "#F76262"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.close()
            }

            Button {
                text: "Save changes" // Changed
                font.pixelSize: 16
                Layout.preferredWidth: 160
                Layout.preferredHeight: 45
                background: Rectangle { color: "#20B990"; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    root.updateRequested(root.itemId, titleInput.text, usernameInput.text, passwordInput.text, websiteInput.text, noteInput.text)
                    root.close()
                }
            }
        }
    }
}