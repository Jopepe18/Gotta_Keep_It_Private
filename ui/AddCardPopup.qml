import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 500
    height: 750
    title: "Add credit card"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#1E2634"


    signal saved(string title, string holder, string number, string cvv, string expiry, string pin, string type, string note)

    Connections {
        target: vaultBackend
        function onOperation_finished(success, message) {
            if (success) {
                console.log("Save success, closing popup")
                root.close() 
            } else {
                validationErrorLabel.text = message
            }
    }
}
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 15

        Label {
            text: "Add new card"
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Title
        ColumnLayout { 
            spacing: 5
            Label { text: "Card title"; color: "#B5B5B5"; font.pixelSize: 14 } // Changed
            TextField { id: titleInput; Layout.fillWidth: true; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } } 
        }

        // Holder name
        ColumnLayout { 
            spacing: 5
            Label { text: "Cardholder name"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField { id: holderInput; Layout.fillWidth: true; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } } 
        }

        // Card number
        ColumnLayout { 
            spacing: 5
            Label { text: "Card number"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField { id: numberInput; maximumLength: 19; Layout.fillWidth: true; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; placeholderText: "XXXX XXXX XXXX XXXX"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }} 
        }

        // Row for CVV & expiry & PIN
        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            
            ColumnLayout { 
                spacing: 5
                Label { text: "CVV"; color: "#B5B5B5"; font.pixelSize: 14 }
                TextField { id: cvvInput; maximumLength: 4; Layout.preferredWidth: 90; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } }
            }
            ColumnLayout { 
                spacing: 5
                Label { text: "Exp (MM/YY)"; color: "#B5B5B5"; font.pixelSize: 14 }
                TextField { 
                    id: expiryInput; inputMask: "99/99"; Layout.preferredWidth: 120; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } }
            }
            ColumnLayout { 
                visible: false
                spacing: 5
                Label { text: "PIN"; color: "#B5B5B5"; font.pixelSize: 14 }
                TextField { id: pinInput; Layout.preferredWidth: 90; Layout.preferredHeight: 45; font.pixelSize: 16; color: "white"; echoMode: TextInput.Password; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } }
            }
        }

        // Card type combobox
        ColumnLayout { 
            spacing: 5
            Label { text: "Card type"; color: "#B5B5B5"; font.pixelSize: 14 }
            ComboBox {
                id: typeInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                model: ["Visa", "Mastercard", "Other"]
                font.pixelSize: 16
                
                background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
                contentItem: Text { text: parent.displayText; color: "white"; font: parent.font; verticalAlignment: Text.AlignVCenter; leftPadding: 10 }
                
                delegate: ItemDelegate {
                    width: typeInput.width
                    contentItem: Text {
                        text: modelData
                        color: "white"
                        font: typeInput.font
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: highlighted ? "#5093E9" : "#303946"
                    }
                    highlighted: typeInput.highlightedIndex === index
                }
                
                popup: Popup {
                    y: parent.height - 1
                    width: parent.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: typeInput.popup.visible ? typeInput.delegateModel : null
                        currentIndex: typeInput.highlightedIndex
                    }
                    background: Rectangle { color: "#303946"; border.color: "white" }
                }
            }
        }

        // Note
        ColumnLayout { 
            spacing: 5
            Label { text: "Note"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextArea { id: noteInput; Layout.fillWidth: true; Layout.preferredHeight: 80; font.pixelSize: 16; color: "white"; background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 } }
        }

        //Error field Label 
        Label {
            id: validationErrorLabel
            text: ""
            visible: text !== ""
            color: '#e15b5b'
            font.pixelSize: 15
            font.italic: true
            Layout.alignment: Qt.AlignHCenter     
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30
            Button { text: "Cancel"; font.pixelSize: 16; Layout.preferredWidth: 140; Layout.preferredHeight: 45; background: Rectangle { color: "transparent"; border.color: "#F76262"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "#F76262"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    validationErrorLabel.text = ""
                    root.close()
                } 
            }
            Button { text: "Add"; font.pixelSize: 16; Layout.preferredWidth: 140; Layout.preferredHeight: 45; background: Rectangle { color: "#5093E9"; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {  
                    validationErrorLabel.text = ""
                    root.saved(titleInput.text, holderInput.text, numberInput.text, cvvInput.text, expiryInput.text, pinInput.text, typeInput.currentText, noteInput.text)
                    //root.close()
                }
            }
        }
    }
}
