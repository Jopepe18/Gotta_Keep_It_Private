import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 500
    height: 750
    title: "Edit credit card"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#2B3441"

    // Properties to receive data
    property int cardId: -1
    property string userId: ""
    property string masterPassword: ""
    property string titleText: ""
    property string holderText: ""
    property string numberText: ""
    property string cvvText: ""
    property string expiryText: ""
    property string cardTypeText: ""
    property string noteText: ""

    signal updated(int cardId, string title, string holder, string number, string cvv, string expiry, string type, string note)
    signal deleted(int cardId)

    // Confirmation popup for deleting card
    ConfirmationPopup {
        id: deleteCardConfirmation
        titleText: "Delete Card"
        messageText: "Are you sure you want to delete this card? This action cannot be undone."
        confirmButtonText: "Delete"
        onConfirmed: {
            console.log("Deleting card from edit popup, ID: " + root.cardId)
            root.deleted(root.cardId)
            root.close()
        }
    }

    Connections {
        target: vaultBackend
        function onOperation_finished(success, message) {
            if (success) {
                console.log("Edit success, closing popup")
                validationErrorLabel.text = ""
                root.close() 
            } else {
                validationErrorLabel.text = message
            }
         }
    }

    // Populate fields when properties change
    function populateFields() {
        titleInput.text = root.titleText
        holderInput.text = root.holderText
        numberInput.text = root.numberText
        cvvInput.text = root.cvvText
        expiryInput.text = root.expiryText
        noteInput.text = root.noteText
        // Set combo box index based on card type
        var typeIndex = typeInput.model.indexOf(root.cardTypeText)
        if (typeIndex >= 0) {
            typeInput.currentIndex = typeIndex
        }
    }

    // Update number/cvv when decrypted asynchronously
    onNumberTextChanged: numberInput.text = root.numberText
    onCvvTextChanged: cvvInput.text = root.cvvText

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 15

        Label {
            text: "Edit Card"
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Title
        ColumnLayout { 
            spacing: 5
            Layout.fillWidth: true
            Label { text: "Card title"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField { 
                id: titleInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#1E2634"; radius: 10 }
            } 
        }

        // Holder name
        ColumnLayout { 
            spacing: 5
            Layout.fillWidth: true
            Label { text: "Cardholder name"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField { 
                id: holderInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#1E2634"; radius: 10 }
            } 
        }

        // Card number
        ColumnLayout { 
            spacing: 5
            Layout.fillWidth: true
            Label { text: "Card number"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextField { 
                id: numberInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 16
                color: "white"
                placeholderText: "XXXX XXXX XXXX XXXX"
                placeholderTextColor: "#B5B5B5"
                background: Rectangle { color: "#1E2634"; radius: 10 }
            } 
        }

        // Row for CVV & expiry
        RowLayout {
            spacing: 20
            Layout.fillWidth: true
            
            ColumnLayout { 
                spacing: 5
                Label { text: "CVV"; color: "#B5B5B5"; font.pixelSize: 14 }
                TextField { 
                    id: cvvInput
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 45
                    font.pixelSize: 16
                    color: "white"
                    background: Rectangle { color: "#1E2634"; radius: 10 }
                }
            }
            ColumnLayout { 
                spacing: 5
                Label { text: "Exp (MM/YY)"; color: "#B5B5B5"; font.pixelSize: 14 }
                TextField { 
                    id: expiryInput
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 45
                    font.pixelSize: 16
                    color: "white"
                    background: Rectangle { color: "#1E2634"; radius: 10 }
                }
            }
            Item { Layout.fillWidth: true }
        }

        // Card type combobox
        ColumnLayout { 
            spacing: 5
            Layout.fillWidth: true
            Label { text: "Card type"; color: "#B5B5B5"; font.pixelSize: 14 }
            ComboBox {
                id: typeInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                model: ["Visa", "Mastercard", "Other"]
                font.pixelSize: 16
                
                background: Rectangle { color: "#1E2634"; radius: 10 }
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
                        color: highlighted ? "#5093E9" : "#1E2634"
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
                    background: Rectangle { color: "#1E2634"; border.color: "#555" }
                }
            }
        }

        // Note
        ColumnLayout { 
            spacing: 5
            Layout.fillWidth: true
            Label { text: "Note"; color: "#B5B5B5"; font.pixelSize: 14 }
            TextArea { 
                id: noteInput
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                font.pixelSize: 16
                color: "white"
                background: Rectangle { color: "#1E2634"; radius: 10 }
            }
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
            
            Button { 
                text: "Cancel"
                font.pixelSize: 16
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "white"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    validationErrorLabel.text = ""
                    root.close()}
            }
            
            Button { 
                text: "Save"
                font.pixelSize: 16
                Layout.preferredWidth: 120
                Layout.preferredHeight: 45
                background: Rectangle { color: "#27ae60"; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    validationErrorLabel.text = ""
                    root.updated(
                        root.cardId,
                        titleInput.text,
                        holderInput.text,
                        numberInput.text,
                        cvvInput.text,
                        expiryInput.text,
                        typeInput.currentText,
                        noteInput.text
                    )
                    //root.close()
                }
            }

            Button {
                text: "Delete"
                font.pixelSize: 16
                Layout.preferredWidth: 120
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "#F76262"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "#F76262"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: deleteCardConfirmation.open()
            }
        }
    }
}
