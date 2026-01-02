import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: settingsPage
    width: 1500
    height: 1080

    property string userId: ""
    property string pendingAction: "" // "email" or "password"
    property string currentUsername: "Loading..."
    property string currentEmail: "Loading..."

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
    }

    ResultPopup {
        id: resultPopup
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
                                        text: settingsPage.currentUsername
                                        font.pixelSize: 16
                                        id: userNameTextField
                                        color: "#eaeaea"
                                        readOnly: true

                                        background: Rectangle{
                                            color: "transparent"
                                        }
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

                            Label{
                                text: settingsPage.currentEmail
                                color: "white"
                                font.pixelSize: 18
                            }

                            Rectangle{
                                Layout.preferredWidth: 300
                                color: "#ACACAC"
                                Layout.preferredHeight: 2
                                radius: 8
                                opacity: 0.3
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

                    Rectangle
                    {
                        Layout.preferredWidth: 180
                        Layout.preferredHeight: 70
                        border.color: "#E22323"
                        border.width: 2
                        radius: 20
                        color: "#1E2634"

                        RowLayout{
                            anchors.fill: parent
                            anchors.margins: 10

                            Item{
                                Layout.preferredWidth: 20
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

                            }
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
                                    color: changeEmailButton.pressed ? "#F76262" : (changeEmailButton.hovered? "#F54040" : "#E22323" )

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
                                        color: changePasswordButton.pressed ? "#F76262" : (changePasswordButton.hovered? "#F54040" : "#E22323" )

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
}