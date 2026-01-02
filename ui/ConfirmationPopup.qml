import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: 400
    height: 200
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay

    property string titleText: "Confirmation"
    property string messageText: "Are you sure?"
    property string confirmButtonText: "Confirm"
    
    signal confirmed()

    background: Rectangle {
        color: "#303946"
        radius: 10
        border.color: "#5093E9"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: popup.titleText
            color: "white"
            font.bold: true
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: popup.messageText
            color: "#eaeaea"
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Cancel"
                onClicked: popup.close()
                background: Rectangle {
                    color: "#555"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: popup.confirmButtonText
                onClicked: {
                    popup.confirmed()
                    popup.close()
                }
                background: Rectangle {
                    color: "#5093E9"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
