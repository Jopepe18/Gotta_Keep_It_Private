import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 500
    height: 720
    title: "Password Details"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#2B3441"

    // Properties to accept data
    property int itemId: -1
    property string titleText: ""
    property string userId: "" // Needed for delete/add
    property string masterPassword: "" // Needed for encryption
    property string usernameText: ""
    property string passwordText: ""
    property string websiteText: ""
    property string noteText: ""
    property string lastModifiedText: ""
    property string createdText: ""
    property bool isFavorite: false
    
    // Mode
    property bool isAdding: false
    property bool isEditing: false

    ConfirmationPopup {
        id: deleteConfirmationPopup
        titleText: "Delete Password"
        messageText: "Are you sure you want to delete this password? This action cannot be undone."
        confirmButtonText: "Delete"
        onConfirmed: {
            console.log("Deleting password id: " + root.itemId)
            vaultBackend.deletePassword(root.itemId, root.userId)
            root.close()
        }
    }
    
    // Signal for operation completion
    Connections {
        target: vaultBackend
        function onOperation_finished(success, message) {
            if(success && (root.isAdding || root.isEditing)) {
                console.log("Save success, closing popup")
                root.close()
            }
        }
    }

    // Helper to reset fields
    function resetFields() {
        titleField.text = ""
        usernameField.text = ""
        passwordField.text = ""
        websiteField.text = ""
        noteField.text = ""
    }

    // Helper to populate fields from properties (restoring data)
    function populateFields() {
        titleField.text = root.titleText
        usernameField.text = root.usernameText
        passwordField.text = root.passwordText
        websiteField.text = root.websiteText
        noteField.text = root.noteText
    }

    // Ensure password field updates when the property changes (async decryption)
    onPasswordTextChanged: {
        passwordField.text = root.passwordText
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 20

        Label {
            text: root.isAdding ? "Add New Password" : (root.isEditing ? "Edit Password" : root.titleText)
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            elide: Text.ElideRight
            Layout.maximumWidth: parent.width
        }
        
        TextField {
            id: titleField
            placeholderText: "Title (e.g. Gmail)"
            placeholderTextColor: "#B5B5B5"
            // text: binding removed, handled by populateFields/resetFields
            visible: root.isAdding || root.isEditing
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            font.pixelSize: 16
            color: "white"
            background: Rectangle { color: "#1E2634"; radius: 10 }
        }

        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: scrollView.availableWidth // Explicitly bind to ScrollView width
                spacing: 20

                // Username
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Label { text: "Username"; color: "#B5B5B5"; font.pixelSize: 14 }
                    TextField {
                        id: usernameField
                        // text: binding removed
                        readOnly: !root.isAdding && !root.isEditing
                        Layout.fillWidth: true // Fill the parent ColumnLayout
                        Layout.preferredHeight: 45
                        font.pixelSize: 16
                        color: "white"
                        background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
                    }
                }

                // Password
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Label { text: "Password"; color: "#B5B5B5"; font.pixelSize: 14 }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        color: "#1E2634"
                        radius: 10
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            TextField {
                                id: passwordField
                                // text: binding removed
                                readOnly: !root.isAdding && !root.isEditing
                                Layout.fillWidth: true
                                font.pixelSize: 16
                                color: "white"
                                echoMode: showPassBtn.checked ? TextInput.Normal : TextInput.Password
                                background: Rectangle { color: "transparent" }
                            }
                            Button {
                                id: showPassBtn
                                checkable: true
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                background: Rectangle { color: "transparent" }
                                contentItem: Image {
                                    source: showPassBtn.checked ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                        }
                    }
                }

                // Website
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Label { text: "Website"; color: "#B5B5B5"; font.pixelSize: 14 }
                    TextField {
                        id: websiteField
                        // text: binding removed
                        readOnly: !root.isAdding && !root.isEditing
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        font.pixelSize: 16
                        color: "white"
                        background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
                    }
                }

                // Note
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    Label { text: "Note"; color: "#B5B5B5"; font.pixelSize: 14 }
                    TextArea {
                        id: noteField
                        // text: binding removed
                        readOnly: !root.isAdding && !root.isEditing
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        font.pixelSize: 16
                        color: "white"
                        background: Rectangle { color: "#303946"; radius: 10; border.color: "white"; border.width: 1 }
                    }
                }

                // Dates
                RowLayout {
                    spacing: 20
                    visible: !root.isAdding
                    Label { text: "Created: " + root.createdText; color: "#B5B5B5"; font.pixelSize: 12 }
                    Label { text: "Modified: " + root.lastModifiedText; color: "#B5B5B5"; font.pixelSize: 12 }
                }
            }
        }

        // Buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            // Save Button (Only visible in Add mode)
            Button {
                text: "Save"
                font.pixelSize: 16
                visible: root.isAdding || root.isEditing
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "#27ae60"; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    if (root.isAdding) {
                        console.log("Saving new password for user: " + root.userId)
                        vaultBackend.addPassword(
                            root.userId,
                            root.masterPassword,
                            titleField.text,
                            usernameField.text,
                            passwordField.text,
                            websiteField.text,
                            noteField.text
                        )
                    } else if (root.isEditing) {
                        console.log("Updating password id: " + root.itemId)
                        vaultBackend.updatePassword(
                            root.userId,
                            root.itemId,
                            root.masterPassword,
                            titleField.text,
                            usernameField.text,
                            passwordField.text,
                            websiteField.text,
                            noteField.text
                        )
                    }
                }
            }

            Button {
                text: "Delete"
                font.pixelSize: 16
                visible: !root.isAdding
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "#F76262"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "#F76262"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: deleteConfirmationPopup.open()
            }

            Button {
                text: "Close"
                font.pixelSize: 16
                Layout.preferredWidth: 140
                Layout.preferredHeight: 45
                background: Rectangle { color: "transparent"; border.color: "white"; border.width: 2; radius: 20 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.close()
            }
        }

    }
}
