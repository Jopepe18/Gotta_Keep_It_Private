

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
    // anchors.fill:parent removed to avoid StackView conflict
    property alias rectangle_subMain_color: rectangle_login_sub.main_color
    property alias rectangle_subBlue: rectangle_login_sub.blue
    property alias rectangle_subBackround_color: rectangle_login_sub.backround_color
    property alias rectangle_subColor: rectangle_login_sub.color

    property string userIdString: ""
    property bool hasExistingVault: false

    signal logoutClicked()
    signal loadMain()

    Connections {
        target: vaultBackend
        function onVault_created(success, message) {
            if(success) {
                console.log("Vault Created: " + message)
                // Update local state to disable New Vault and enable Main
                root.hasExistingVault = true
                root.loadMain() // Navigate to Main
            } else {
                console.log("Vault Creation Failed: " + message)
            }
        }
    }

    Rectangle {
        id: rectangle_login
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
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    clip: false

                    Button {
                        id: button_newvault
                        height: 90
                        text: qsTr("New Vault")
                        font.pointSize: 15
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 50
                        Layout.rightMargin: 50
                        enabled: !root.hasExistingVault
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: {
                            console.log("Creating vault for user: " + root.userIdString)
                            vaultBackend.create_vault(root.userIdString, "My New Vault", "", "")
                        }
                    }

                    Button {
                        id: button_importvault
                        height: 90
                        text: qsTr("Import Vault")
                        font.pointSize: 15
                        flat: false
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 50
                        Layout.rightMargin: 50
                        enabled: !root.hasExistingVault
                        opacity: enabled ? 1.0 : 0.5
                    }

                    Button {
                        id: button_logout
                        height: 50
                        text: qsTr("Logout")
                        font.pointSize: 15
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 50
                        Layout.rightMargin: 50
                        onClicked: root.logoutClicked()
                    }

                     Button {
                        id: button_gotoMain
                        height: 50
                        text: qsTr("Main")
                        font.pointSize: 15
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.leftMargin: 50
                        Layout.rightMargin: 50
                        enabled: root.hasExistingVault
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: root.loadMain()
                    }
                    
                }
            }

            ColumnLayout {
                id: img_column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: rectangle_login_sub.top
                anchors.margins: 20
                uniformCellSizes: false
                layoutDirection: Qt.LeftToRight
                transformOrigin: Item.Center
                spacing: 30

                Label {
                    id: title_label
                    width: img_column.width
                    height: 30
                    text: qsTr("Gotta Keep It Private")
                    color: "#eaeaea"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.pointSize: 32
                }
            }
        }
    }
}
