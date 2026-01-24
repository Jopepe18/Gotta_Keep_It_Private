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
    
    // TOTP properties
    property string totpCode: ""
    property bool hasTotp: false
    property string totpSecret: ""  // For editing/adding
    
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
    
    // TOTP Setup Popup
    Popup {
        id: totpSetupPopup
        anchors.centerIn: parent
        width: 400
        height: 250
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#2B3441"
            radius: 15
            border.color: "#5093E9"
            border.width: 2
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Label {
                text: "Setup Two-Factor Authentication"
                color: "white"
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Label {
                text: "Enter the secret key provided by your authenticator app or service:"
                color: "#B5B5B5"
                font.pixelSize: 13
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            
            TextField {
                id: totpSecretInput
                placeholderText: "e.g., JBSWY3DPEHPK3PXP"
                placeholderTextColor: "#888"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                font.pixelSize: 14
                color: "white"
                background: Rectangle { 
                    color: "#303946"
                    radius: 10
                    border.color: "#5093E9"
                    border.width: 1 
                }
            }
            
            Label {
                id: totpErrorLabel
                text: ""
                color: "#F76262"
                font.pixelSize: 12
                visible: text !== ""
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                Button {
                    text: "Cancel"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "transparent"; border.color: "white"; border.width: 2; radius: 10 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        totpSecretInput.text = ""
                        totpErrorLabel.text = ""
                        totpSetupPopup.close()
                    }
                }
                
                Button {
                    text: "Save"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#5093E9"; radius: 10 }
                    contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        var secret = totpSecretInput.text.trim().toUpperCase().replace(/\s/g, "")
                        if (secret.length < 16) {
                            totpErrorLabel.text = "Secret key is too short (minimum 16 characters)"
                            return
                        }
                        // Save the secret
                        root.totpSecret = secret
                        root.hasTotp = true
                        totpSecretInput.text = ""
                        totpErrorLabel.text = ""
                        totpSetupPopup.close()
                        console.log("TOTP secret saved: " + secret.substring(0, 4) + "...")
                    }
                }
            }
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
        root.totpSecret = ""
        root.hasTotp = false
        root.totpCode = ""
    }

    // Helper to populate fields from properties (restoring data)
    function populateFields() {
        titleField.text = root.titleText
        usernameField.text = root.usernameText
        passwordField.text = root.passwordText
        websiteField.text = root.websiteText
        noteField.text = root.noteText
        // totpSecret stays empty in edit mode (user doesn't see existing secret)
        // hasTotp and totpCode are set from outside
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

                // 2FA / TOTP Section
                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true
                    
                    RowLayout {
                        spacing: 10
                        Label { text: "Two-Factor Authentication (2FA)"; color: "#B5B5B5"; font.pixelSize: 14 }
                        Label { 
                            text: root.hasTotp ? "✓ Enabled" : "○ Not Set"
                            color: root.hasTotp ? "#27ae60" : "#888"
                            font.pixelSize: 12
                            visible: !root.isAdding && !root.isEditing
                        }
                    }
                    
                    // TOTP Code Display (View mode with TOTP)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        color: "#1E2634"
                        radius: 10
                        border.color: root.hasTotp ? "#5093E9" : "#555"
                        border.width: 1
                        visible: !root.isAdding && !root.isEditing && root.hasTotp
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            ColumnLayout {
                                spacing: 2
                                Label { text: "Current Code"; color: "#B5B5B5"; font.pixelSize: 12 }
                                Label { 
                                    text: root.totpCode || "------"
                                    color: "#5093E9"
                                    font.pixelSize: 28
                                    font.bold: true
                                    font.family: "Menlo"
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "Copy"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 35
                                background: Rectangle { color: "#5093E9"; radius: 10 }
                                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: {
                                    if (root.totpCode) {
                                        // Use a hidden TextField to copy
                                        totpCopyHelper.text = root.totpCode
                                        totpCopyHelper.selectAll()
                                        totpCopyHelper.copy()
                                        console.log("TOTP code copied to clipboard")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Hidden helper for clipboard copy
                    TextField {
                        id: totpCopyHelper
                        visible: false
                    }
                    
                    // Setup/Edit 2FA Button (Add/Edit mode)
                    Button {
                        text: root.hasTotp ? "Change 2FA Secret" : "Setup 2FA"
                        Layout.preferredHeight: 45
                        Layout.fillWidth: true
                        visible: root.isAdding || root.isEditing
                        background: Rectangle { 
                            color: "transparent"
                            border.color: "#5093E9"
                            border.width: 2
                            radius: 10 
                        }
                        contentItem: Text { 
                            text: parent.text
                            color: "#5093E9"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }
                        onClicked: totpSetupPopup.open()
                    }
                    
                    // TOTP Secret Input Field (shown after clicking Setup)
                    TextField {
                        id: totpSecretField
                        placeholderText: "Enter 2FA Secret Key"
                        placeholderTextColor: "#888"
                        visible: false  // Hidden, managed by popup
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        font.pixelSize: 14
                        color: "white"
                        background: Rectangle { color: "#303946"; radius: 10; border.color: "#5093E9"; border.width: 1 }
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
                            noteField.text,
                            root.totpSecret  // TOTP secret
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
                            noteField.text,
                            root.totpSecret  // TOTP secret (empty = no change, has value = update)
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
