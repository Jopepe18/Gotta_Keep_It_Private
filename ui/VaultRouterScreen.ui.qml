/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    property string userIdString: ""
    property string vaultPassword: "" // Password for vault creation
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
        id: background
        anchors.fill: parent
        color: "#1E1E1E"

        Rectangle {
            id: mainCard
            width: 600
            height: 450
            anchors.centerIn: parent
            color: "#1E2634"
            radius: 20

            ColumnLayout {
                id: mainColumn
                anchors.fill: parent
                spacing: 0

                // Vault Icon
                Image {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 150
                    source: "../imgs/safe.png"
                    Layout.topMargin: 40
                    Layout.alignment: Qt.AlignHCenter
                    fillMode: Image.PreserveAspectFit
                }

                // Title
                Label {
                    text: qsTr("Your Vault")
                    color: "#eaeaea"
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 28
                    font.weight: Font.Medium
                    Layout.topMargin: 15
                }

                // Subtitle
                Label {
                    text: root.hasExistingVault 
                        ? qsTr("Access your secure vault")
                        : qsTr("Create a new vault to get started")
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                    font.pointSize: 14
                    Layout.topMargin: 5
                    Layout.bottomMargin: 25
                }

                // Buttons Container
                Rectangle {
                    id: buttonsContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    Layout.leftMargin: 50
                    Layout.rightMargin: 50
                    Layout.bottomMargin: 40
                    color: "#303946"
                    radius: 15

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 25
                        spacing: 15

                        // Message Text (for errors)
                        Label {
                            id: messageText
                            text: ""
                            color: "#c50000"
                            visible: false
                            Layout.alignment: Qt.AlignHCenter
                            font.pointSize: 12
                        }

                        // New Vault Button
                        Button {
                            id: buttonNewVault
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            visible: !root.hasExistingVault
                            
                            background: Rectangle {
                                color: buttonNewVault.hovered ? "#4a8fe7" : "#3d7fd6"
                                radius: 10
                            }
                            
                            contentItem: Text {
                                text: qsTr("🔐  Create New Vault")
                                color: "white"
                                font.pointSize: 15
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                console.log("Creating vault for user: " + root.userIdString)
                                vaultBackend.create_vault(root.userIdString, "My New Vault", root.vaultPassword, root.vaultPassword)
                            }
                        }

                        // Continue to Main Button (only if has vault)
                        Button {
                            id: buttonMain
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            visible: root.hasExistingVault
                            
                            background: Rectangle {
                                color: buttonMain.hovered ? "#4a8fe7" : "#3d7fd6"
                                radius: 10
                            }
                            
                            contentItem: Text {
                                text: qsTr("🔓  Open Vault")
                                color: "white"
                                font.pointSize: 15
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: root.loadMain()
                        }

                        // Spacer
                        Item {
                            Layout.fillHeight: true
                        }

                        // Logout Button
                        Button {
                            id: buttonLogout
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            
                            background: Rectangle {
                                color: buttonLogout.hovered ? "#4a4a4a" : "transparent"
                                radius: 8
                                border.color: "#666666"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: qsTr("← Logout")
                                color: "#aaaaaa"
                                font.pointSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: root.logoutClicked()
                        }
                    }
                }
            }
        }
    }
}
