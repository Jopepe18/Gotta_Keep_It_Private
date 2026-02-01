
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1500
    height: 1080

    signal loginRequested()
    signal registerSuccess(string key, string userId, string password)

    property bool visiblePassword: false

    Connections {
        target: registerBackend
        function onRegister_status(success, message, secret_key, user_id) {
            if (success) {
                console.log("Registration successful: " + message)
                message_text.color = "green"
                message_text.text = "Success"
                root.registerSuccess(secret_key, user_id, textfield_password.text)
            } else {
                console.log("Registration failed: " + message)
                message_text.color = "#c50000"
                message_text.text = message
            }
        }
    }

    Rectangle{
        id: rectangle_register_window
        width: 1500
        height: 1080
        color: "#1E1E1E"

        Rectangle{
            id: rectangle_register_main
            color: "#1E2634"
            radius: 20
            width: 600
            height: 1080
            anchors.centerIn: parent

            ColumnLayout{
                id: img_column
                anchors.fill: parent
                anchors.margins: 30

                 Image {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 150
                    source: "../imgs/user.png"
                    Layout.topMargin: 30
                    Layout.alignment: Qt.AlignHCenter
                    fillMode: Image.PreserveAspectFit
                    Layout.bottomMargin: 10
                }

                Label{
                    width: img_column.width
                    height: 30
                    text: qsTr("Create account")
                    color: "#eaeaea"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 25
                    Layout.bottomMargin: 10
                } 

                Rectangle{
                    id: rectangle_register_sub
                    Layout.preferredHeight: 580
                    Layout.fillWidth: true
                    color: "#303946"
                    Layout.rightMargin: 50
                    Layout.leftMargin: 50
                    radius: 20
                    clip: true

                    ColumnLayout{
                        id: credentials_column
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.rightMargin: 50
                        anchors.leftMargin: 50
                        spacing: 6
                        clip: true

                        Text {
                        id: label_username
                        width: 100
                        height: 40
                        color: "#eaeaea"
                        text: qsTr("Username")
                        font.pixelSize: 20
                        Layout.fillWidth: false
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.fillWidth: true
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                 anchors.fill: parent
                                 anchors.margins: 5 
                                 
                                 TextField {
                                     id: textfield_username
                                     font.pointSize: 17
                                     Layout.fillWidth: true
                                     placeholderText: qsTr("")
                                     color: "#eaeaea"
                                     background: Rectangle { color: "transparent" }
                                 }
                            }
                        }

                        Text {
                            id: label_email
                            color: "#eaeaea"
                            text: qsTr("Email")
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.fillWidth: true
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                 anchors.fill: parent
                                 anchors.margins: 5 
                                 
                                 TextField {
                                     id: textfield_email
                                     font.pointSize: 17
                                     Layout.fillWidth: true
                                     placeholderText: qsTr("")
                                     color: "#eaeaea"
                                     background: Rectangle { color: "transparent" }
                                 }
                            }
                        }

                        Text {
                            id: label_password
                            color: "#eaeaea"
                            text: qsTr("Password")
                            font.pixelSize: 20
                        }

                        Rectangle{
                            Layout.preferredHeight: 45
                            Layout.fillWidth: true
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout{
                                anchors.fill: parent
                                spacing: 10

                                TextField {
                                    id: textfield_password
                                    font.pointSize: 17
                                    Layout.fillWidth: true
                                    color: "#eaeaea"

                                    background: Rectangle{
                                        color: "transparent"
                                    }

                                    echoMode: visiblePassword ? TextInput.Normal : TextInput.Password
                                }

                                Button{
                                    id: eyeButton
                                    Layout.preferredHeight: 35
                                    Layout.preferredWidth: 35
                                    Layout.rightMargin: 10
                                    Layout.topMargin: 5

                                    background: Rectangle{
                                        color: eyeButton.pressed? "#3A4354" : (eyeButton.hovered? "#2D3749": "transparent")
                                        radius: 20
                                    }

                                    contentItem: Rectangle{
                                        anchors.fill: parent
                                        color: "transparent"

                                        Image{
                                            height: 30
                                            width: 30
                                            source: visiblePassword ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }

                                    onClicked:{
                                        visiblePassword = !visiblePassword;
                                    }
                                }
                            }



                        }

                        // Password Strength Indicator
                        ColumnLayout {
                            id: strengthIndicator
                            Layout.fillWidth: true
                            spacing: 4
                            visible: textfield_password.text.length > 0

                            // Helper properties for password strength
                            property int passLength: textfield_password.text.length
                            property bool hasLowercase: /[a-z]/.test(textfield_password.text)
                            property bool hasUppercase: /[A-Z]/.test(textfield_password.text)
                            property bool hasSpecialChar: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(textfield_password.text)
                            property bool has8Chars: passLength >= 8
                            property bool isStrong: has8Chars && hasLowercase && hasUppercase && hasSpecialChar
                            property bool isMedium: passLength >= 4 && !isStrong
                            property bool isWeak: passLength > 0 && passLength < 4

                            property color strengthColor: {
                                if (isStrong) return "#4CAF50"  // Green
                                if (isMedium) return "#FFC107"  // Yellow
                                return "#F44336"  // Red
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

                            // Missing Criteria Hints (only show when not strong)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                visible: !strengthIndicator.isStrong && strengthIndicator.passLength >= 4

                                Text {
                                    text: strengthIndicator.has8Chars ? "✓ 8+" : "○ 8+"
                                    color: strengthIndicator.has8Chars ? "#4CAF50" : "#888888"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: strengthIndicator.hasLowercase ? "✓ abc" : "○ abc"
                                    color: strengthIndicator.hasLowercase ? "#4CAF50" : "#888888"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: strengthIndicator.hasUppercase ? "✓ ABC" : "○ ABC"
                                    color: strengthIndicator.hasUppercase ? "#4CAF50" : "#888888"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: strengthIndicator.hasSpecialChar ? "✓ @#$" : "○ @#$"
                                    color: strengthIndicator.hasSpecialChar ? "#4CAF50" : "#888888"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Text {
                            id: text_confirmpass
                            color: "#eaeaea"
                            text: qsTr("Confirm Password")
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.fillWidth: true
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                 anchors.fill: parent
                                 spacing: 10
                                 
                                 TextField {
                                     id: textfield_confirmpass
                                     font.pointSize: 17
                                     Layout.fillWidth: true
                                     placeholderText: qsTr("")
                                     echoMode: visiblePassword ? TextInput.Normal : TextInput.Password
                                     color: "#eaeaea"
                                     background: Rectangle { color: "transparent" }
                                 }

                                 Button{
                                     id: eyeButtonConfirm
                                     Layout.preferredHeight: 35
                                     Layout.preferredWidth: 35
                                     Layout.rightMargin: 10
                                     Layout.topMargin: 5

                                     background: Rectangle{
                                         color: eyeButtonConfirm.pressed? "#3A4354" : (eyeButtonConfirm.hovered? "#2D3749": "transparent")
                                         radius: 20
                                     }

                                     contentItem: Rectangle{
                                         anchors.fill: parent
                                         color: "transparent"

                                         Image{
                                             height: 30
                                             width: 30
                                             source: visiblePassword ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                             fillMode: Image.PreserveAspectFit
                                         }
                                     }

                                     onClicked:{
                                         visiblePassword = !visiblePassword;
                                     }
                                 }
                            }
                        }

                    Text {
                        id: message_text
                        text: ""
                        color: "red"
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                    }

                    

                        Button {
                            id: register_action_button
                            Layout.preferredWidth: 180
                            Layout.preferredHeight: 50
                            Layout.topMargin: 10
                            text: qsTr("Register")
                            font.pointSize: 18
                            
                            Layout.alignment: Qt.AlignRight

                            background: Rectangle{
                                color: register_action_button.pressed ? "#619DEC" : (register_action_button.hovered ? "#4F91E8" : "#4080D4")
                                radius: 30
                            }

                            onClicked: {
                                // Validate password strength (minimum 4 characters)
                                if (textfield_password.text.length < 4) {
                                    message_text.color = "#F44336"
                                    message_text.text = "Password must be at least 4 characters"
                                    return
                                }
                                registerBackend.attempt_register(textfield_username.text, textfield_email.text, textfield_password.text, textfield_confirmpass.text)
                            }
                        }

                        Item {
                            Layout.preferredHeight: 10
                        }

                        Text {
                            text: qsTr("Already registered? Sign In")
                            color: "#bdc3c7"
                            font.pixelSize: 15
                            font.underline: true
                            Layout.alignment: Qt.AlignHCenter
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.loginRequested()
                            }
                        }
                    

                        Item{
                            Layout.fillHeight: true
                        }
                    }

                }



                Item{
                    Layout.fillHeight: true
                } 
            }

        }
    }
}
