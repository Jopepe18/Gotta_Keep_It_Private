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

    property string titleText: "Result"
    property string messageText: ""
    property bool isSuccess: true
    
    background: Rectangle {
        color: "#303946"
        radius: 10
        border.color: popup.isSuccess ? "#2ECC71" : "#E74C3C"
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: popup.titleText
            color: popup.isSuccess ? "#2ECC71" : "#E74C3C"
            font.bold: true
            font.pixelSize: 22
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

        Button {
            text: "OK"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            
            onClicked: popup.close()
            
            background: Rectangle {
                color: popup.isSuccess ? "#2ECC71" : "#E74C3C"
                radius: 5
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
        }
    }
}
