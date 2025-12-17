
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
//code generated, δεν χρησιμοποιηθηκε απο το Qt Designer
Page {
    id: root
    
    signal verifyRequested(string username, string email, string key)
    signal loginRequested()
    signal recoveryVerified(string username, string key)
    
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
                }

                // Verify Button
                Button {
                    text: qsTr("Verify Identity")
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.topMargin: 10
                    
                    background: Rectangle {
                        color: parent.down ? "#2980b9" : "#3498db"
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
                message_text.color = "green"
                message_text.text = message // "Match"
                // Pass the matched username and key to the next screen
                root.recoveryVerified(textfield_username.text, textfield_key.text)
            } else {
                message_text.color = "red"
                message_text.text = message // "No Match"
            }
        }
    }
}
