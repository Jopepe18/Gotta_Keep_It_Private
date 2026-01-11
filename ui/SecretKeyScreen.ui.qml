

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
    property alias buttonIconcolor: continue_button.icon.color
    property alias rectangle_subMain_color: rectangle_login_sub.main_color
    property alias rectangle_subBlue: rectangle_login_sub.blue
    property alias rectangle_subBackround_color: rectangle_login_sub.backround_color
    property alias rectangle_subColor: rectangle_login_sub.color

    property string secretKey: ""
    signal continueClicked()

    Rectangle {
        id: rectangle_login
        x: 41
        y: 24
        width: 1500
        height: 1080
        color: rectangle_login_sub.backround_color
        radius: 0

        Rectangle {
            id: rectangle_login_main
            color: rectangle_login_sub.main_color
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
                id: rectangle_login_sub
                color: sub_color
                radius: 25
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 105
                anchors.rightMargin: 133
                anchors.topMargin: 264
                anchors.bottomMargin: 406
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
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    anchors.topMargin: 7
                    anchors.bottomMargin: -2
                    spacing: 0
                    clip: false

                    Text {
                        id: label_secretkey
                        width: 100
                        height: 40
                        color: "#eaeaea"
                        text: qsTr("Secret Key")
                        font.pixelSize: rectangle_login_main.text_size
                        Layout.fillWidth: false
                        Layout.topMargin: 10
                        Layout.leftMargin: 60
                    }

                    TextField {
                        id: textfield_secretkey
                        font.pointSize: 18
                        Layout.topMargin: -40
                        Layout.fillWidth: true
                        Layout.rightMargin: 50
                        Layout.leftMargin: 50
                        placeholderText: qsTr("")
                        text: root.secretKey
                        readOnly: true
                    }

                    Text {
                        id: label_warning
                        color: "#c50000"
                        text: qsTr("#Warning: Secret key cannot be retrieved if lost")
                        font.pixelSize: rectangle_login_main.text_size
                        Layout.topMargin: 20
                        Layout.leftMargin: 60
                    }
                }
            }

            ColumnLayout {
                id: img_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: rectangle_login_sub.top
                anchors.leftMargin: 150
                anchors.rightMargin: 178
                anchors.topMargin: 98
                anchors.bottomMargin: -6
                uniformCellSizes: false
                layoutDirection: Qt.LeftToRight
                transformOrigin: Item.Center
                spacing: 30

                Label {
                    id: title_label
                    width: img_column.width
                    height: 30
                    text: qsTr("Gotta Keep It Private")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 32
                }
            }
        }

        Button {
            id: continue_button
            x: 875
            y: 725
            width: 200
            height: 70
            text: qsTr("Continue")
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
            onClicked: root.continueClicked()
        }
    }
}
