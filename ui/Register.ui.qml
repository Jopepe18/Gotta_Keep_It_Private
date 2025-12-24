
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
    property alias rectangle_subMain_color: rectangle_register_sub.main_color
    property alias rectangle_subBlue: rectangle_register_sub.blue
    property alias rectangle_subBackround_color: rectangle_register_sub.backround_color
    property alias rectangle_subColor: rectangle_register_sub.color

    signal loginRequested()
    signal registerSuccess(string key, string userId)

    Connections {
        target: registerBackend
        function onRegister_status(success, message, secret_key, user_id) {
            if (success) {
                console.log("Registration successful: " + message)
                message_text.color = "green"
                message_text.text = "Success"
                root.registerSuccess(secret_key, user_id)
            } else {
                console.log("Registration failed: " + message)
                message_text.color = "#c50000"
                message_text.text = message
            }
        }
    }

    Rectangle {
        id: rectangle_register_window
        x: 0
        y: 0
        width: 1500
        height: 1080
        color: rectangle_register_sub.backround_color
        radius: 0

        Rectangle {
            id: rectangle_register_main
            color: rectangle_register_sub.main_color
            radius: 15
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 300
            anchors.rightMargin: 300
            anchors.topMargin: 40
            anchors.bottomMargin: 40
            property int text_size: 25

            Rectangle {
                id: rectangle_register_sub
                color: sub_color
                radius: 25
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 142
                anchors.rightMargin: 158
                anchors.topMargin: 357
                anchors.bottomMargin: 143
                property color blue: "#3d7fd6"
                property color backround_color: "#1e1e1e"
                property color sub_color: "#303a46"
                property color main_color: "#1d2532"

                ColumnLayout {
                    id: credentials_column
                    visible: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.topMargin: 8
                    anchors.bottomMargin: 0
                    spacing: 0
                    clip: false

                    Text {
                        id: label_username
                        width: 100
                        height: 40
                        color: "#eaeaea"
                        text: qsTr("Username")
                        font.pixelSize: rectangle_register_main.text_size
                        Layout.fillWidth: false
                        Layout.topMargin: 5
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_username
                        font.pointSize: 18
                        Layout.topMargin: 5
                        Layout.fillWidth: true
                        Layout.rightMargin: 50
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                    }

                    Text {
                        id: label_password
                        color: "#eaeaea"
                        text: qsTr("Password")
                        font.pixelSize: rectangle_register_main.text_size
                        Layout.topMargin: 0
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_password
                        z: 0
                        font.pointSize: 18
                        Layout.topMargin: 5
                        Layout.rightMargin: 50
                        Layout.fillWidth: true
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                    }

                    Text {
                        id: label_email
                        color: "#eaeaea"
                        text: qsTr("Email")
                        font.pixelSize: rectangle_register_main.text_size
                        Layout.topMargin: 0
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_email
                        font.pointSize: 18
                        Layout.topMargin: 5
                        Layout.rightMargin: 50
                        Layout.fillWidth: true
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                    }


                    Text {
                        id: text_confirmpass
                        color: "#eaeaea"
                        text: qsTr("Confirm Password")
                        font.pixelSize: rectangle_register_main.text_size
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_confirmpass
                        Layout.topMargin: 5
                        Layout.rightMargin: 50
                        Layout.leftMargin: 50
                        Layout.fillWidth: true
                        placeholderText: qsTr("")
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 50
                        spacing: 20
                        Layout.topMargin: 20

                        Label {
                            text: qsTr("Already user?")
                            color: "#eaeaea"
                            font.pointSize: 14
                        }

                        Button {
                            text: qsTr("Login")
                            display: AbstractButton.TextOnly
                            flat: true
                            font.pointSize: 14
                            font.underline: true
                            onClicked: root.loginRequested()
                        }

                        Button {
                            id: register_action_button
                            width: 200
                            height: 70
                            text: qsTr("Register")
                            focusPolicy: Qt.ClickFocus
                            highlighted: true
                            flat: false
                            checkable: false
                            display: AbstractButton.TextOnly
                            rightInset: 10
                            leftInset: 10
                            font.pointSize: 18
                            icon.width: 30
                            onClicked: {
                                registerBackend.attempt_register(textfield_username.text, textfield_email.text, textfield_password.text, textfield_confirmpass.text)
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: img_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: rectangle_register_sub.top
                anchors.leftMargin: 150
                anchors.rightMargin: 178
                anchors.topMargin: 0
                anchors.bottomMargin: 35
                uniformCellSizes: false
                layoutDirection: Qt.LeftToRight
                transformOrigin: Item.Center
                spacing: 30

                Image {
                    id: img_user
                    width: 200
                    height: 200
                    source: "../imgs/user_icon.png"
                    Layout.topMargin: 30
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: img_label
                    width: img_column.width
                    height: 30
                    text: qsTr("Create Account")
                    color: "#eaeaea"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 25
                }
            }


        }
    }
}
