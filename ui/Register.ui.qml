
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
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
                    Layout.preferredHeight: 470
                    Layout.fillWidth: true
                    color: "#303946"
                    Layout.rightMargin: 50
                    Layout.leftMargin: 50
                    radius: 20

                    ColumnLayout{
                        id: credentials_column
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.rightMargin: 50
                        anchors.leftMargin: 50
                        spacing: 8
                        clip: false

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
                                 anchors.margins: 5 
                                 
                                 TextField {
                                     id: textfield_confirmpass
                                     font.pointSize: 17
                                     Layout.fillWidth: true
                                     placeholderText: qsTr("")
                                     echoMode: TextInput.Password
                                     color: "#eaeaea"
                                     background: Rectangle { color: "transparent" }
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
                                registerBackend.attempt_register(textfield_username.text, textfield_email.text, textfield_password.text, textfield_confirmpass.text)
                            }
                        }
                    

                        Item{
                            Layout.fillHeight: true
                        }
                    }

                }

                RowLayout{
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                     Label {
                            text: qsTr("Already have an account?")
                            color: "#eaeaea"
                            font.pointSize: 17
                        }

                        Button {
                            display: AbstractButton.TextOnly
                            flat: true
                            onClicked: root.loginRequested()

                            contentItem: Text{
                                text: "Sign In"
                                color: "#73AAF3"
                                font.pointSize: 17
                                font.underline: true
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
