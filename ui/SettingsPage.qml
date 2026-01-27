import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs // for FileDialog

Item{
    id: settingsPage
    width: 1500
    height: 1080

    property string userId: ""
    property string pendingAction: "" // "email" or "password"
    property string currentUsername: "Loading..."
    property string currentEmail: "Loading..."
    property string _tempPass: ""  //save password while the user picks a file location
    

    Component.onCompleted: {
        if(userId !== "") {
            vaultBackend.getUserInfo(userId)
        }
    }
    
    onUserIdChanged: {
         if(userId !== "") {
            vaultBackend.getUserInfo(userId)
        }
    }

    Connections {
        target: vaultBackend
        function onUserInfoReceived(username, email) {
            settingsPage.currentUsername = username
            settingsPage.currentEmail = email
        }

        function onOperation_finished(success, message) {
            console.log("Operation finished: " + success + " - " + message)
            
            resultPopup.titleText = success ? "Success" : "Error"
            resultPopup.messageText = message
            resultPopup.isSuccess = success
            resultPopup.open()
            
            // Refund fields or update UI if success
            if (success) {
                 if (settingsPage.pendingAction === "email") {
                     settingsPage.currentEmail = newEmailTextField.text // Optimistic update or refetch
                     newEmailTextField.text = ""
                     newEmailPasswordVerifTextField.text = ""
                 } else if (settingsPage.pendingAction === "password") {
                     currentPasswordTextField.text = ""
                     newPasswordfTextField.text = ""
                     confirmNewPasswordfTextField.text = ""
                 }
            }
        }

        function onVaultDeleted(success, message) {
            if (!success) {
                resultPopup.titleText = "Error"
                resultPopup.messageText = message
                resultPopup.isSuccess = false
                resultPopup.open()
            }
        }

        function onPasswordVerified(success, message) {
            if (success) {
                // password correct
                genericPasswordPopup.close()
                
                if (settingsPage.pendingAction === "EXPORT") {
                    exportFileDialog.open()
                } else if (settingsPage.pendingAction === "IMPORT") {
                    importFileDialog.open()
                }
            } else {
                // failed. change warning label message
                genericPasswordPopup.showErrorMessage(message)  //"Wrong Password. Please try again."
            }
        }

        //if i want import/export final success message
        function onVaultHandled(success, message) {
            resultPopup.titleText = success ? "Success" : "Error"
            resultPopup.messageText = message
            resultPopup.isSuccess = success
            resultPopup.open()      
            // Safety: Wipe password from memory
            settingsPage._tempPass = ""   
        }
    }

    ResultPopup {
        id: resultPopup
    }

    DeleteVaultPopup {
        id: deleteVaultPopup
        onConfirmed: function(password) {
            vaultBackend.deleteVault(settingsPage.userId, password)
        }
    }

    ConfirmationPopup {
        id: confirmationPopup
        onConfirmed: {
            if (settingsPage.pendingAction === "email") {
                vaultBackend.changeEmail(settingsPage.userId, newEmailTextField.text, newEmailPasswordVerifTextField.text)
            } else if (settingsPage.pendingAction === "password") {
                vaultBackend.changeMasterPassword(settingsPage.userId, currentPasswordTextField.text, newPasswordfTextField.text)
            }
        }
    }

    //import and export
    PasswordPrompt {
        id: genericPasswordPopup
        onConfirmed: (password) => {
            // Store password for the later export/import call
            settingsPage._tempPass = password       
            // Ask Python to verify BEFORE opening FileDialog
            vaultBackend.check_password_before_action(settingsPage.userId, password)
        }
    }

    FileDialog {
        id: exportFileDialog
        title: "Choose where to save your export"
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)"]
        
        onAccepted: {
            // selectedFile gives a URL like "file:///path/file.json"
            // Use Qt.resolvedUrl to get proper path handling
            var path = selectedFile.toString()
            
            // Remove file:// prefix but preserve the leading / on Unix systems
            if (Qt.platform.os === "windows") {
                // Windows: file:///C:/path -> C:/path
                path = path.replace(/^file:\/\/\//, "")
            } else {
                // macOS/Linux: file:///path -> /path
                path = path.replace(/^file:\/\//, "")
            }
            
            // Call python function
            vaultBackend.export_vault(settingsPage.userId, settingsPage._tempPass, path)        
        }
    }

    FileDialog{
        id:importFileDialog
        title: "Choose what file to import"
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON files (*.json)"]
        onAccepted: {
            var clean_path = selectedFile.toString()
            
            // Remove file:// prefix but preserve the leading / on Unix systems
            if (Qt.platform.os === "windows") {
                // Windows: file:///C:/path -> C:/path
                clean_path = clean_path.replace(/^file:\/\/\//, "")
            } else {
                // macOS/Linux: file:///path -> /path
                clean_path = clean_path.replace(/^file:\/\//, "")
            }
            
            //send to Python
            vaultBackend.import_vault(userId, settingsPage._tempPass, clean_path)
        }
    }

   Rectangle{
    color: "#1E2634"
    anchors.fill: parent

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 20
            spacing: 30

            RowLayout{
                Layout.fillWidth: true

                ColumnLayout{

                    Label{
                    text: "Settings"
                    color: "white"
                    font.pointSize: 28
                    }

                    /*---------Username/Email Display and Danger Zone--------*/
                    RowLayout{
                        Layout.fillWidth: true
                        spacing: 50
                        
                        /*-------Username Column and Text Field----------*/
                        ColumnLayout{
                            
                            Label{
                                text: "Username"
                                color: "white"
                                font.pixelSize:16
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 300
                                radius: 20
                                color: "#252D36"
                                border.color: "#555"
                                border.width: 1

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 10

                                    Text{
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        text: settingsPage.currentUsername
                                        font.pixelSize: 16
                                        color: "#ACACAC"
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }  
                        }

                        /*------Email Display---------*/
                        ColumnLayout{

                            Label{
                                text: "Email"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 300
                                radius: 20
                                color: "#252D36"
                                border.color: "#555"
                                border.width: 1

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    
                                    Text{
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        text: settingsPage.currentEmail
                                        font.pixelSize: 16
                                        color: "#ACACAC"
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        Item{
                            Layout.fillWidth: true
                        }


                    }
                }

                
                ColumnLayout{
                    Layout.preferredWidth: 440

                    Label{
                        text: "Danger Zone"
                        color: "#E22323"
                        font.pixelSize: 20
                    }

                    RowLayout {
                        spacing: 15

                        Rectangle
                        {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 70
                            border.color: "#E22323"
                            border.width: 2
                            radius: 20
                            color: "#1E2634"

                            RowLayout{
                                anchors.fill: parent
                                anchors.margins: 10

                                Item{
                                    Layout.fillWidth: true
                                }

                                Button{
                                    text:"Delete"
                                    id: deleteVaultButton
                                    Layout.preferredHeight: 45
                                    Layout.preferredWidth: 100
                                    font.pixelSize: 17

                                    background: Rectangle{
                                        radius: 20
                                        color: deleteVaultButton.pressed ? "#F76262" : (deleteVaultButton.hovered? "#F54040" : "#E22323" )

                                        Behavior on color{
                                        ColorAnimation { duration: 150}
                                        }
                                    }
                                    onClicked: deleteVaultPopup.open()
                                }

                                Item{
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // About Button (discrete, outside danger zone)
                        Button {
                            id: aboutButton
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 40
                            
                            background: Rectangle {
                                color: aboutButton.hovered ? "#3a4555" : "transparent"
                                radius: 20
                                border.color: "#555"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: "ℹ️"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: aboutButton.hovered ? 1.0 : 0.5
                            }
                            
                            ToolTip.visible: hovered
                            ToolTip.delay: 300
                            ToolTip.text: "About"
                            
                            onClicked: aboutPopup.open()
                        }
                    }

                }
            }

            /*-----------Change UserName and Password Row---------*/
            RowLayout{
                Layout.fillWidth: true
                spacing: 50

                /*---------Change Email Column---------*/
                ColumnLayout{
                    Layout.margins: 10
                    spacing: 10

                    Label{
                        text: "Change Email"
                        color: "white"
                        font.pixelSize: 20
                    }

                    Rectangle{
                        Layout.preferredHeight: 350
                        Layout.preferredWidth: 400
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"

                        ColumnLayout{
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            Label{
                                text:"New Email"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 350
                                radius: 20
                                color: "#1E2634"
                                border.color: "white"

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.topMargin:5
                                    anchors.bottomMargin: 5
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextField{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: ""
                                        font.pixelSize: 16
                                        id: newEmailTextField
                                        color: "#eaeaea"
                                        placeholderText: "Enter new email"

                                        background: Rectangle{
                                            color: "transparent"
                                        }
                                    }
                                }
                            }

                            Item{
                                Layout.preferredHeight: 20
                            }

                            Label{
                                text:"Password (required)"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 350
                                radius: 20
                                color: "#1E2634"
                                border.color: "white"

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.topMargin:5
                                    anchors.bottomMargin: 5
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextField{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: ""
                                        font.pixelSize: 16
                                        id: newEmailPasswordVerifTextField
                                        color: "#eaeaea"
                                        echoMode: TextInput.Password
                                        placeholderText: "Confirm password"

                                        background: Rectangle{
                                            color: "transparent"
                                        }
                                    }
                                }
                            }

                            Item{
                                Layout.preferredHeight: 20
                            }

                            RowLayout{
                                Layout.fillWidth: true

                                Item{
                                    Layout.fillWidth: true
                                }

                                Button{
                                id: changeEmailButton
                                text: "Change Email"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 150

                                background: Rectangle{
                                    radius:20
                                    color: changeEmailButton.pressed ? "#619DEC" : (changeEmailButton.hovered ? "#4F91E8" : "#4080D4")

                                    Behavior on color{
                                        ColorAnimation { duration: 150}
                                    }
                                }
                                onClicked: {
                                    if(newEmailTextField.text === "" || newEmailPasswordVerifTextField.text === "") return;
                                    settingsPage.pendingAction = "email"
                                    confirmationPopup.titleText = "Change Email"
                                    confirmationPopup.messageText = "Are you sure you want to change your email to " + newEmailTextField.text + "?"
                                    confirmationPopup.confirmButtonText = "Confirm"
                                    confirmationPopup.open()
                                }
                            }
                            }

                            Item{
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Item{
                        Layout.preferredHeight: 20
                    }

                    Label{
                        text: "Vault Settings"
                        color: "white"
                        font.pixelSize: 20
                    }

                    Rectangle{
                        Layout.preferredHeight: 70
                        Layout.preferredWidth: 450
                        color: "#1E2634"
                        border.color: "white"
                        radius: 20

                        RowLayout{
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10

                            Button{
                                id: importVaultButton
                                text: "Import"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 110

                                background: Rectangle{
                                    radius:20
                                    color: importVaultButton.pressed ? "#83C8DA" : (importVaultButton.hovered? "#6CA9B9" : "#599BAA" )

                                    Behavior on color{
                                        ColorAnimation { duration: 150}
                                    }
                                }

                                onClicked: {
                                    settingsPage.pendingAction = "IMPORT"         
                                    genericPasswordPopup.open()
                                    //genericPasswordPopup.titleText = "Enter Password to Import Vault"
                                }
                            }

                            Item{
                                Layout.fillWidth: true
                            }
                            
                            Button{
                                id: exportVaultButton
                                text: "Export"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 110

                                background: Rectangle{
                                    radius:20
                                    color: exportVaultButton.pressed ? "#F29A7A" : (exportVaultButton.hovered? "#E28462" : "#FA681F" )

                                    Behavior on color{
                                        ColorAnimation { duration: 150}
                                    }
                                }

                                onClicked: {
                                    settingsPage.pendingAction = "EXPORT"
                                    genericPasswordPopup.open()
                                    //genericPasswordPopup.titleText = "Enter Password to Export Vault"
                                }
                            }
                        }
                    }
                    
                
                }

                /*---------Change Password Column---------*/
                ColumnLayout{
                    Layout.margins: 10
                    spacing: 10

                    Label{
                        text: "Change Password"
                        color: "white"
                        font.pixelSize: 20
                    }

                    Rectangle{
                        Layout.preferredHeight: 470
                        Layout.preferredWidth: 400
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"

                        ColumnLayout{
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10

                            Label{
                                text:"Current Password"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 350
                                radius: 20
                                color: "#1E2634"
                                border.color: "white"

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.topMargin:5
                                    anchors.bottomMargin: 5
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextField{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: ""
                                        font.pixelSize: 16
                                        id: currentPasswordTextField
                                        color: "#eaeaea"
                                        echoMode: TextInput.Password

                                        background: Rectangle{
                                            color: "transparent"
                                        }
                                    }
                                }
                            }

                            Item{
                                Layout.preferredHeight: 20
                            }

                            Label{
                                text:"New Password"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 350
                                radius: 20
                                color: "#1E2634"
                                border.color: "white"

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.topMargin:5
                                    anchors.bottomMargin: 5
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextField{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: ""
                                        font.pixelSize: 16
                                        id: newPasswordfTextField
                                        color: "#eaeaea"
                                        echoMode: TextInput.Password

                                        background: Rectangle{
                                            color: "transparent"
                                        }
                                    }
                                }
                            }

                            Item{
                                Layout.preferredHeight: 20
                            }

                            Label{
                                text:"Confirm New Password"
                                color: "white"
                                font.pixelSize: 20
                            }

                            Rectangle{
                                Layout.preferredHeight: 50
                                Layout.preferredWidth: 350
                                radius: 20
                                color: "#1E2634"
                                border.color: "white"

                                RowLayout{
                                    anchors.fill: parent
                                    anchors.topMargin:5
                                    anchors.bottomMargin: 5
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10

                                    TextField{
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text: ""
                                        font.pixelSize: 16
                                        id: confirmNewPasswordfTextField
                                        color: "#eaeaea"
                                        echoMode: TextInput.Password

                                        background: Rectangle{
                                            color: "transparent"
                                        }
                                    }
                                }
                            }

                            Item{
                                Layout.preferredHeight: 20
                            }

                            RowLayout{
                                Layout.fillWidth: true

                                Item{
                                    Layout.fillWidth: true
                                }

                                Button{
                                id: changePasswordButton
                                text: "Change Password"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 150

                                    background: Rectangle{
                                        radius:20
                                        color:  changePasswordButton.pressed ? "#619DEC" : (changePasswordButton.hovered ? "#4F91E8" : "#4080D4")

                                        Behavior on color{
                                            ColorAnimation { duration: 150}
                                        }
                                    }
                                    onClicked: {
                                        if(currentPasswordTextField.text === "" || newPasswordfTextField.text === "" || confirmNewPasswordfTextField.text === "") return;
                                        if (newPasswordfTextField.text !== confirmNewPasswordfTextField.text) {
                                            confirmationPopup.titleText = "Error"
                                            confirmationPopup.messageText = "Passwords do not match."
                                            confirmationPopup.confirmButtonText = "OK"
                                            confirmationPopup.open()
                                            return;
                                        }

                                        settingsPage.pendingAction = "password"
                                        confirmationPopup.titleText = "Change Password"
                                        confirmationPopup.messageText = "Are you sure you want to change your master password?"
                                        confirmationPopup.confirmButtonText = "Confirm"
                                        confirmationPopup.open()
                                    }
                                }
                            }

                           
                        }
                        
                    }

                    Item{
                        Layout.preferredHeight: 20
                    }
                
                }


            }

            Item{
                Layout.fillHeight: true
            }

        }
    }

    // About Popup
    Popup {
        id: aboutPopup
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 400
        height: 280
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: "#1E2634"
            radius: 20
            border.color: "#3d7fd6"
            border.width: 2
        }
        
        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // Logo/Icon
            Text {
                text: "🔐"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }
            
            // App Name
            Label {
                text: "Gotta Keep It Private"
                color: "#eaeaea"
                font.pixelSize: 22
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Version
            Label {
                text: "v1.0"
                color: "#888888"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Creators Message !
            Label {
                text: "Σχεδιασμένο με αγάπη από ανθρώπους ❤️"
                color: "#a0a0a0"
                font.pixelSize: 15
                font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            // Close Button
            Button {
                id: closeAboutButton
                text: "OK"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 100
                Layout.preferredHeight: 35
                
                background: Rectangle {
                    color: closeAboutButton.hovered ? "#4a8fe7" : "#3d7fd6"
                    radius: 10
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: aboutPopup.close()
            }
        }
    }
}