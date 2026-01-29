
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1500
    height: 800
    
    property string secretKey: ""
    signal continueClicked()
    
    // State for copy feedback
    property bool copied: false

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16222A" }
            GradientStop { position: 1.0; color: "#3A6073" }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15
            width: 450

            // Icon
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignHCenter
                radius: 40
                color: "#2ecc71"
                
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 40
                    color: "white"
                }
            }

            // Title
            Text {
                text: qsTr("Account Created!")
                color: "white"
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Subtitle
            Text {
                text: qsTr("Save your Recovery Key")
                color: "#bdc3c7"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            // Main Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                radius: 12
                color: "#2c3e50"
                border.color: "#34495e"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    // Recovery Key Label
                    Text {
                        text: qsTr("🔑 Your Recovery Key")
                        color: "#ecf0f1"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Key Display Box
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        radius: 8
                        color: "#1a252f"
                        border.color: "#3498db"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.secretKey
                            color: "#3498db"
                            font.pixelSize: 14
                            font.family: "Courier New"
                            font.bold: true
                        }
                    }

                    // Copy Button
                    Button {
                        id: copyButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        
                        background: Rectangle {
                            radius: 8
                            color: root.copied ? "#27ae60" : (copyButton.pressed ? "#2980b9" : (copyButton.hovered ? "#3498db" : "#2c3e50"))
                            border.color: root.copied ? "#27ae60" : "#3498db"
                            border.width: 1
                            
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                        
                        contentItem: Text {
                            text: root.copied ? "✓ Copied!" : "📋 Copy to Clipboard"
                            color: root.copied ? "white" : "#3498db"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            textEdit.text = root.secretKey
                            textEdit.selectAll()
                            textEdit.copy()
                            root.copied = true
                            copyResetTimer.start()
                        }
                    }
                    
                    // Hidden TextEdit for clipboard operations
                    TextEdit {
                        id: textEdit
                        visible: false
                        text: root.secretKey
                    }

                    // Warning
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        radius: 6
                        color: "#3d1c1c"
                        border.color: "#e74c3c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "⚠️ This key cannot be recovered if lost!"
                            color: "#e74c3c"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }
            }

            // Info Text
            Text {
                text: qsTr("You need this key to recover your account.")
                color: "#95a5a6"
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
            }

            // Continue Button
            Button {
                id: continueButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                
                background: Rectangle {
                    radius: 10
                    color: continueButton.pressed ? "#27ae60" : (continueButton.hovered ? "#2ecc71" : "#27ae60")
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: qsTr("Continue →")
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: root.continueClicked()
            }
        }
    }

    // Timer to reset copy state
    Timer {
        id: copyResetTimer
        interval: 2000
        onTriggered: root.copied = false
    }
}
