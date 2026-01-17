import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property string errorText: "" // error label 
    signal confirmed(string password)
    
    // Helper function to show the error from the outside
    function showErrorMessage(msg) {
        errorText = msg
    }

    // Helper function to reset when opening
    onOpened: {
        errorText = ""
        passwordField.text = ""
    }

    width: 400
    height: 250
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay


    background: Rectangle {
        color: "#1E2634"
        border.color: "white"
        border.width: 1
        radius: 20
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Label {
            id: titleLabel
            text: "Confirm Password"
            color: "white"
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: passwordField
            placeholderText: "Enter Master Password"
            echoMode: TextInput.Password
            onTextChanged: root.errorText = "" // Clear error when user starts typing again
            Layout.fillWidth: true
            color: "white"
            font.pixelSize: 16
            verticalAlignment: TextInput.AlignVCenter
            
            background: Rectangle {
                color: "#252D36"
                radius: 10
                border.color: "white"
            }
        }

        Label {
            text: root.errorText
            color: "#FF5555" 
            font.pixelSize: 12
            visible: text !== ""  //only visible when there is a text 
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Confirm"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter
            
            onClicked: {
                if (passwordField.text !== "") {
                    root.confirmed(passwordField.text) // Send password to main page
                    //root.close()  //NOW IT CLOSES FROM THE CONNECTION FUNCTION 
                    //passwordField.text = "" // Clear it for security
                }
            }
        }

    }

    //fucntion to call to change dynamically the error label 
        function showValidationError(msg) {
        errorMessage = msg
        passwordField.text = "" // Clear the wrong password
    }
}