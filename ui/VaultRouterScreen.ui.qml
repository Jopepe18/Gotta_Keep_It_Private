import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    property string userIdString: ""
    property string vaultPassword: ""
    property bool hasExistingVault: false

    signal logoutClicked()
    signal loadMain()

    Connections {
        target: vaultBackend
        function onVault_created(success, message) {
            if(success) {
                console.log("Vault Created: " + message)
                root.hasExistingVault = true
                root.loadMain()
            } else {
                console.log("Vault Creation Failed: " + message)
                messageText.text = message
                messageText.visible = true
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16222A" }
            GradientStop { position: 1.0; color: "#3A6073" }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: 400

            // Vault Icon
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignHCenter
                radius: 50
                color: "#2ecc71"
                
                Text {
                    anchors.centerIn: parent
                    text: "🔐"
                    font.pixelSize: 45
                }
            }

            // Title
            Text {
                text: qsTr("Your Vault")
                color: "white"
                font.pixelSize: 28
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Subtitle
            Text {
                text: root.hasExistingVault 
                    ? qsTr("Access your secure vault")
                    : qsTr("Create a new vault to get started")
                color: "#bdc3c7"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            // Message Text (for errors)
            Text {
                id: messageText
                text: ""
                color: "#e74c3c"
                visible: false
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            // New Vault Button
            Button {
                id: buttonNewVault
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                visible: !root.hasExistingVault
                
                background: Rectangle {
                    color: buttonNewVault.pressed ? "#2980b9" : (buttonNewVault.hovered ? "#3498db" : "#2980b9")
                    radius: 10
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: qsTr("🔐  Create New Vault")
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("Creating vault for user: " + root.userIdString)
                    vaultBackend.create_vault(root.userIdString, "My New Vault", root.vaultPassword, root.vaultPassword)
                }
            }

            // Open Vault Button (only if has vault)
            Button {
                id: buttonMain
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                visible: root.hasExistingVault
                
                background: Rectangle {
                    color: buttonMain.pressed ? "#27ae60" : (buttonMain.hovered ? "#2ecc71" : "#27ae60")
                    radius: 10
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: qsTr("🔓  Open Vault")
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.loadMain()
            }

            // Logout Button
            Button {
                id: buttonLogout
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                Layout.topMargin: 10
                
                background: Rectangle {
                    color: buttonLogout.hovered ? "#34495e" : "transparent"
                    radius: 8
                    border.color: "#7f8c8d"
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: qsTr("← Logout")
                    color: "#bdc3c7"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.logoutClicked()
            }
        }
    }
}
