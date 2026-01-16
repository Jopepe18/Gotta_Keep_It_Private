
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//code generated, δεν χρησιμοποιηθηκε απο το Qt Designer
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
            height: 450
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

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
                    Layout.topMargin: 10
                    
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
