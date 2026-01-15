import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root
    width: 400
    height: 250
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay

    // We use a signal to "shout" the password back to the main page
    signal confirmed(string password)
    property alias titleText: titleLabel.text

    background: Rectangle {
        color: "#1E2634"
        border.color: "white"
        border.width: 1
        radius: 20
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Label {
            id: titleLabel
            text: "Confirm Password"
            color: "white"
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: passwordField
            placeholderText: "Enter Master Password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            color: "white"
            font.pixelSize: 16
            verticalAlignment: TextInput.AlignVCenter
            
            background: Rectangle {
                color: "#252D36"
                radius: 10
                border.color: "white"
            }
        }

        Button {
            text: "Confirm"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            
            onClicked: {
                if (passwordField.text !== "") {
                    root.confirmed(passwordField.text) // Send password to main page
                    root.close()
                    passwordField.text = "" // Clear it for security
                }
            }
        }
    }
}