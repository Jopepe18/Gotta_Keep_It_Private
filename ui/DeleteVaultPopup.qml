import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: 450
    height: 350
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay

    signal confirmed(string password)

    property string messageText: "This action is IRREVERSIBLE. Your account, vault, and all passwords will be permanently deleted."

    background: Rectangle {
        color: "#1E2634" 
        radius: 10
        border.color: "#E22323" // Red warning border
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "DELETE ACCOUNT"
            color: "#E22323"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: popup.messageText
            color: "#eaeaea"
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignCenter
        }
        
        Item { Layout.preferredHeight: 10 }

        Text {
            text: "Enter Master Password to confirm:"
            color: "white"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignLeft
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: "#252D36"
            radius: 5
            border.color: "#555"

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.margins: 10
                color: "white"
                font.pixelSize: 16
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                clip: true
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Cancel"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                onClicked: {
                    passwordInput.text = ""
                    popup.close()
                }
                background: Rectangle {
                    color: "#555"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "DELETE FOREVER"
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                onClicked: {
                    if (passwordInput.text !== "") {
                        popup.confirmed(passwordInput.text)
                        passwordInput.text = "" // Clear for security
                        popup.close()
                    }
                }
                background: Rectangle {
                    color: "#E22323"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }
        }
    }
}
