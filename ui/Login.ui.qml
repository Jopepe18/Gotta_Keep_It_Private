

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
    property alias buttonIconcolor: login_button.icon.color
    property alias rectangle_subMain_color: rectangle_sub.main_color
    property alias rectangle_subBlue: rectangle_sub.blue
    property alias rectangle_subBackround_color: rectangle_sub.backround_color
    property alias rectangle_subColor: rectangle_sub.color

    Rectangle {
        id: rectangle
        x: 0
        y: 0
        width: 1500
        height: 1080
        color: rectangle_sub.backround_color
        radius: 0

        Rectangle {
            id: rectangle_main
            color: rectangle_sub.main_color
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
                id: rectangle_sub
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
                        font.pixelSize: rectangle_main.text_size
                        Layout.fillWidth: false
                        Layout.topMargin: 10
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_username
                        font.pointSize: 18
                        Layout.topMargin: -40
                        Layout.fillWidth: true
                        Layout.rightMargin: 50
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                    }

                    Text {
                        id: label_password
                        color: "#eaeaea"
                        text: qsTr("Password")
                        font.pixelSize: rectangle_main.text_size
                        Layout.topMargin: 20
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_password
                        z: 0
                        font.pointSize: 18
                        Layout.topMargin: -45
                        Layout.rightMargin: 50
                        Layout.fillWidth: true
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                    }

                    Button {
                        id: login_button
                        width: 200
                        height: 70
                        text: qsTr("Login")
                        focusPolicy: Qt.ClickFocus
                        Layout.leftMargin: 330
                        Layout.alignment: Qt.AlignRight | Qt.AlignBaseline
                        highlighted: true
                        flat: false
                        checkable: false
                        display: AbstractButton.TextOnly
                        rightInset: 10
                        leftInset: 10
                        font.pointSize: 18
                        Layout.fillHeight: false
                        icon.width: 30
                        Layout.rightMargin: 50
                        Layout.fillWidth: true
                    }
                }
            }

            ColumnLayout {
                id: img_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: rectangle_sub.top
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
                    source: "../../imgs/user_icon.png"
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
                    text: qsTr("Log in to Gotta Keep It Private")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 25
                }
            }

            RowLayout {
                id: register_column
                x: 318
                y: 892
                width: 237
                height: 79
                spacing: 0

                Label {
                    id: register_label
                    color: "#eaeaea"
                    text: qsTr("New to GKIP?")
                    font.pointSize: 16
                }

                Button {
                    id: register_button
                    text: qsTr("Sign Up")
                    focusPolicy: Qt.ClickFocus
                    display: AbstractButton.TextOnly
                    highlighted: true
                    font.hintingPreference: Font.PreferDefaultHinting
                    flat: true
                    font.pointSize: 16
                    font.underline: true
                    font.bold: false
                    font.italic: false
                }
            }
        }
    }
}
