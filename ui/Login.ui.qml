import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1500
    height: 1080

    signal registerRequested()
    signal loginSuccess(string secretKey, string userId, bool hasVault)
    signal forgotPasswordRequested()
    signal loadMain()

    property bool is_login_success: false
    property string login_message: ""
    property string secret_key_val: ""
    property bool visiblePassword: false

    Connections {
        target: loginBackend
        function onLogin_status(success, message, secret_key, user_id, has_vault) {
            if (success) {
                console.log("Login success: " + message)
                message_text.color = "green"
                message_text.text = message
                root.loginSuccess(secret_key, user_id, has_vault)
            } else {
                console.log("Login failed: " + message)
                message_text.color = "#c50000"
                message_text.text = message
            }
        }
    }

    Rectangle{
        id: rectangle_login
        width: 1500
        height: 1080
        color: "#1E1E1E"

        Rectangle{
        id: rectangle_login_main
        width: 600
        height: 1080
        anchors.centerIn: parent
        color: "#1E2634"
        radius: 20

        ColumnLayout{
            id: img_column
            anchors.fill: parent
            
             Image {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 200
                    source: "../imgs/user_icon.png"
                    Layout.topMargin: 30
                    Layout.alignment: Qt.AlignHCenter
                    fillMode: Image.PreserveAspectFit
                    Layout.bottomMargin: 10
                }

            Label {
                    width: img_column.width
                    height: 30
                    text: qsTr("Log in to Gotta Keep It Private")
                    color: "#eaeaea"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 25
                    Layout.bottomMargin: 20
            }

            Rectangle{
                id: rectangle_login_sub
                Layout.preferredHeight: 350
                Layout.fillWidth: parent
                Layout.leftMargin: 50
                Layout.bottomMargin: 30
                Layout.rightMargin: 50

                color: "#303946"
                radius: 20

                ColumnLayout{
                anchors.fill:parent

                Text {
                id: label_username
                width: 100
                height: 40
                color: "#eaeaea"
                text: qsTr("Username")
                font.pixelSize: 20
                Layout.fillWidth: false
                Layout.topMargin: 20
                Layout.leftMargin: 60
                }

            
                    TextField {
                        id: textfield_username
                        font.pointSize: 17
                        Layout.fillWidth: true
                        Layout.leftMargin:50
                        Layout.rightMargin: 50
                        placeholderText: qsTr("")
                        color: "#eaeaea"

                        background: Rectangle{
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                        }
                    }

                    Text {
                        id: label_password
                        color: "#eaeaea"
                        text: qsTr("Password")
                        font.pixelSize: 20
                        Layout.topMargin: 20
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_password
                        z: 0
                        font.pointSize: 17
                        Layout.topMargin: 5
                        Layout.rightMargin: 50
                        Layout.fillWidth: true
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                        color: "#eaeaea"

                        background: Rectangle{
                            color: "transparent"
                            border.color: "white"
                            radius: 20
                            border.width: 1
                        }
                    }

                    Text {
                        id: message_text
                        text: ""
                        color: "red"
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                    }

                    RowLayout{
                        Layout.fillWidth: true
                        Layout.rightMargin: 50
                        Layout.leftMargin: 50
                        Layout.bottomMargin: 30

                        Button {
                        text: qsTr("Forgot Password?")
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 50
                        
                        
                        background: Rectangle { color: "transparent" }
                        contentItem: Text {
                            text: parent.text
                            color: "#eaeaea"
                            font.underline: true
                            font.pixelSize: 16
                        }
                        onClicked: root.forgotPasswordRequested()
                        }

                        Item{
                            Layout.fillWidth: true
                        }


                        Button {
                            id: login_button
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 55
                            text: qsTr("Login")
                            font.pointSize: 18

                            background: Rectangle{
                                color: login_button.pressed ? "#619DEC" : (login_button.hovered ? "#4F91E8" : "#4080D4")
                                radius: 30
                            }

                            onClicked: {
                                loginBackend.attempt_login(textfield_username.text, textfield_password.text)
                            }
                        }
                    }

                }
            }

            RowLayout{
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Label {
                            text: qsTr("New to GKIP?")
                            color: "#eaeaea"
                            font.pointSize: 17
                        }

                        Button {
                            display: AbstractButton.TextOnly
                            flat: true
                            onClicked: root.registerRequested()

                            contentItem: Text{
                                text: "Sign Up"
                                color: "#73AAF3"
                                font.pointSize: 17
                                font.underline: true
                            }
                        }
            }
                

            Item{
                Layout.preferredHeight: 600
            }
        }
        }

    }
}
