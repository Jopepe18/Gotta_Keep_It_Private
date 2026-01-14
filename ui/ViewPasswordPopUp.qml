import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 500
    height: 720
    title: "Password Details"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#1E2634"

    // Properties to accept data
    property int itemId: -1
    property string titleText: ""
    property string userId: "" // Needed for delete
    property string usernameText: ""
    property string passwordText: ""
    property string websiteText: ""
    property string noteText: ""
    property string lastModifiedText: ""
    property string createdText: ""
    property bool isFavorite: false

    ConfirmationPopup {
        id: deleteConfirmationPopup
        titleText: "Delete Password"
        messageText: "Are you sure you want to delete this password? This action cannot be undone."
        confirmButtonText: "Delete"
        onConfirmed: {
            console.log("Deleting password id: " + root.itemId)
            vaultBackend.deletePassword(root.itemId, root.userId)
            root.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        Label {
            text: root.titleText
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            elide: Text.ElideRight
            Layout.maximumWidth: parent.width
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 20

                // Username
                ColumnLayout {
                    spacing: 5
                    Label { text: "Username"; color: "#B5B5B5"; font.pixelSize: 14 }
                    TextField {
                        text: root.usernameText
                        readOnly: true
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
                                text: root.passwordText
                                readOnly: true
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
                        text: root.websiteText
                        readOnly: true
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
                        text: root.noteText
                        readOnly: true
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        font.pixelSize: 16
                        color: "white"
                        background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
                    }
                }

                // Dates
                RowLayout {
                    spacing: 20
                    Label { text: "Created: " + root.createdText; color: "#B5B5B5"; font.pixelSize: 12 }
                    Label { text: "Modified: " + root.lastModifiedText; color: "#B5B5B5"; font.pixelSize: 12 }
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Delete"
                font.pixelSize: 16
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "#F76262"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "#F76262"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: deleteConfirmationPopup.open()
            }

            Button {
                text: "Close"
                font.pixelSize: 16
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "white"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.close()
            }
        }

    }
}
