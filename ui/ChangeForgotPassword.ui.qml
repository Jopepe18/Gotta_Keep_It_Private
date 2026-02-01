
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    
    property string username: ""
    property string secretKey: ""
    
    signal changePasswordSuccess(string userId, bool hasVault, string newPassword)
    signal backRequested()
    
    // Background
    Rectangle {
        id: rectangle_main
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16222A" }
            GradientStop { position: 1.0; color: "#3A6073" }
        }

        Rectangle {
            id: rectangle_box
            color: "#2c3e50"
            radius: 10
            anchors.centerIn: parent
            width: 380
            height: 520
            clip: true
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Text {
                    text: qsTr("Reset Password")
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: qsTr("Set a new password for " + root.username)
                    color: "#bdc3c7"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // New Password
                Text {
                    color: "#eaeaea"
                    text: qsTr("New Password")
                    font.pixelSize: 16
                }

                TextField {
                    id: textfield_newpass
                    font.pointSize: 14
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Enter new password")
                }

                // Password Strength Indicator
                ColumnLayout {
                    id: strengthIndicator
                    Layout.fillWidth: true
                    spacing: 4
                    visible: textfield_newpass.text.length > 0

                    // Helper properties for password strength
                    property int passLength: textfield_newpass.text.length
                    property bool hasLowercase: /[a-z]/.test(textfield_newpass.text)
                    property bool hasUppercase: /[A-Z]/.test(textfield_newpass.text)
                    property bool hasSpecialChar: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(textfield_newpass.text)
                    property bool has8Chars: passLength >= 8
                    property bool isStrong: has8Chars && hasLowercase && hasUppercase && hasSpecialChar
                    property bool isMedium: passLength >= 4 && !isStrong
                    property bool isWeak: passLength > 0 && passLength < 4

                    property color strengthColor: {
                        if (isStrong) return "#4CAF50"
                        if (isMedium) return "#FFC107"
                        return "#F44336"
                    }

                    property string strengthText: {
                        if (isStrong) return "Strong password ✓"
                        if (isMedium) return "Medium strength"
                        return "Too weak (min 4 characters)"
                    }

                    property real strengthPercent: {
                        if (isStrong) return 1.0
                        if (passLength >= 8) return 0.75
                        if (passLength >= 6) return 0.55
                        if (passLength >= 4) return 0.4
                        if (passLength >= 2) return 0.2
                        return 0.1
                    }

                    // Strength Bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#1E2634"

                        Rectangle {
                            width: parent.width * strengthIndicator.strengthPercent
                            height: parent.height
                            radius: 3
                            color: strengthIndicator.strengthColor

                            Behavior on width {
                                NumberAnimation { duration: 200 }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    // Strength Text
                    Text {
                        text: strengthIndicator.strengthText
                        color: strengthIndicator.strengthColor
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignLeft
                    }

                    // Missing Criteria Hints
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: !strengthIndicator.isStrong && strengthIndicator.passLength >= 4

                        Text {
                            text: strengthIndicator.has8Chars ? "✓ 8+" : "○ 8+"
                            color: strengthIndicator.has8Chars ? "#4CAF50" : "#888888"
                            font.pixelSize: 10
                        }
                        Text {
                            text: strengthIndicator.hasLowercase ? "✓ abc" : "○ abc"
                            color: strengthIndicator.hasLowercase ? "#4CAF50" : "#888888"
                            font.pixelSize: 10
                        }
                        Text {
                            text: strengthIndicator.hasUppercase ? "✓ ABC" : "○ ABC"
                            color: strengthIndicator.hasUppercase ? "#4CAF50" : "#888888"
                            font.pixelSize: 10
                        }
                        Text {
                            text: strengthIndicator.hasSpecialChar ? "✓ @#$" : "○ @#$"
                            color: strengthIndicator.hasSpecialChar ? "#4CAF50" : "#888888"
                            font.pixelSize: 10
                        }
                    }
                }

                // Confirm Password
                Text {
                    color: "#eaeaea"
                    text: qsTr("Confirm Password")
                    font.pixelSize: 16
                }

                TextField {
                    id: textfield_confirmpass
                    font.pointSize: 14
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: qsTr("Confirm new password")
                }
                
                Text {
                    id: message_text
                    text: ""
                    color: "white"
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignHCenter
                }

                // Change Button
                Button {
                    text: qsTr("Change Password")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    
                    background: Rectangle {
                        color: parent.down ? "#27ae60" : "#2ecc71"
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 18
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        // Validate password strength (minimum 4 characters)
                        if (textfield_newpass.text.length < 4) {
                            message_text.color = "#F44336"
                            message_text.text = "Password must be at least 4 characters"
                            return
                        }
                        forgotPasswordBackend.attempt_recovery_change(
                            root.username, 
                            root.secretKey, 
                            textfield_newpass.text, 
                            textfield_confirmpass.text
                        )
                    }
                }
                
                // Cancel
                Button {
                    text: qsTr("Cancel")
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle { color: "transparent" }
                    contentItem: Text {
                        text: parent.text
                        color: "#95a5a6"
                        font.pixelSize: 14
                    }
                    onClicked: root.backRequested()
                }
            }
        }
    }
    
    Connections {
        target: forgotPasswordBackend
        function onVerify_status(success, message, userId, hasVault) {
            if (success && message === "Password Changed Successfully") {
                message_text.color = "green"
                message_text.text = "Success!"
                root.changePasswordSuccess(userId, hasVault, textfield_newpass.text)
            } else if (!success) {
                message_text.color = "red"
                message_text.text = message
            }
        }
    }
}
