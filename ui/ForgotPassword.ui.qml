
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//code generated, δεν χρησιμοποιηθηκε απο το Qt Designer
Page {
    id: root
    
    signal verifyRequested(string username, string email, string key)
    signal loginRequested()
    signal recoveryVerified(string username, string key)
    
    // Lockout properties
    property int failedAttempts: 0
    property int maxAttempts: 4
    property bool isLockedOut: false
    property int lockoutSeconds: 300  // 5 minutes
    property int remainingLockoutSeconds: 0

    // Lockout Timer
    Timer {
        id: lockoutTimer
        interval: 1000
        repeat: true
        running: root.isLockedOut
        onTriggered: {
            root.remainingLockoutSeconds--
            if (root.remainingLockoutSeconds <= 0) {
                root.isLockedOut = false
                root.failedAttempts = 0
                root.remainingLockoutSeconds = 0
                message_text.text = ""
                lockoutTimer.stop()
            } else {
                var minutes = Math.floor(root.remainingLockoutSeconds / 60)
                var seconds = root.remainingLockoutSeconds % 60
                var timeStr = minutes + ":" + (seconds < 10 ? "0" : "") + seconds
                message_text.text = "Too many failed attempts. Try again in " + timeStr
                message_text.color = "#F44336"
            }
        }
    }
    
    // Background
    Rectangle {
        id: rectangle_main
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16222A" }
            GradientStop { position: 1.0; color: "#3A6073" }
        }

        property int text_size: 16       

        Rectangle {
            id: rectangle_center
            color: "#2c3e50"
            radius: 10
            anchors.centerIn: parent
            width: 380
            height: 520
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: qsTr("Recovery")
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }
                
                // Username
                Text {
                    color: "#eaeaea"
                    text: qsTr("Username")
                    font.pixelSize: rectangle_main.text_size
                }

                TextField {
                    id: textfield_username
                    font.pointSize: 14
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter your username")
                }

                // Email
                Text {
                    color: "#eaeaea"
                    text: qsTr("Email")
                    font.pixelSize: rectangle_main.text_size
                }

                TextField {
                    id: textfield_email
                    font.pointSize: 14
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter your email")
                }

                // Secret Key
                Text {
                    color: "#eaeaea"
                    text: qsTr("Secret Key")
                    font.pixelSize: rectangle_main.text_size
                }

                TextField {
                    id: textfield_key
                    font.pointSize: 14
                    Layout.fillWidth: true
                    placeholderText: qsTr("XXXX-XXXX-XXXX-XXXX")
                }
                
                // Status Message
                Text {
                    id: message_text
                    text: ""
                    color: "red"
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // Verify Button
                Button {
                    id: verifyButton
                    text: root.isLockedOut ? qsTr("Locked") : qsTr("Verify Identity")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.topMargin: 10
                    enabled: !root.isLockedOut
                    
                    background: Rectangle {
                        color: {
                            if (!verifyButton.enabled) return "#666666"
                            return parent.down ? "#2980b9" : "#3498db"
                        }
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
                        if (root.isLockedOut) {
                            return
                        }
                        forgotPasswordBackend.attempt_verify(textfield_username.text, textfield_email.text, textfield_key.text)
                    }
                }
                
                // Back to Login
                Button {
                    text: qsTr("Back to Login")
                    Layout.alignment: Qt.AlignHCenter
                    background: Rectangle { color: "transparent" }
                    contentItem: Text {
                        text: parent.text
                        color: "#3498db"
                        font.pixelSize: 14
                    }
                    onClicked: root.loginRequested()
                }
            }
        }
    }
    
    Connections {
        target: forgotPasswordBackend
        
        function onVerify_status(success, message) {
            if (success) {
                // Reset failed attempts on success
                root.failedAttempts = 0
                message_text.color = "green"
                message_text.text = message
                root.recoveryVerified(textfield_username.text, textfield_key.text)
            } else {
                root.failedAttempts++
                
                var attemptsRemaining = root.maxAttempts - root.failedAttempts
                
                if (attemptsRemaining <= 0) {
                    root.isLockedOut = true
                    root.remainingLockoutSeconds = root.lockoutSeconds
                    lockoutTimer.start()
                    message_text.color = "#F44336"
                    message_text.text = "Too many failed attempts. Try again in 5:00"
                } else {
                    message_text.color = "#F44336"
                    message_text.text = message + " (" + attemptsRemaining + " attempts left)"
                }
            }
        }
    }
}
