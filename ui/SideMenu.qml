import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: 1500
    height: 1080

    signal logoutClicked()
    property string currentPage: "passwords"
    property string userIdString: ""
    property string masterPassword: ""

    //  ΣΥΝΔΕΣΗ ΜΕ ΤΗ ΒΑΣΗ ΓΙΑ LOGOUT
    Connections {
        target: vaultBackend
        function onVaultDeleted(success, message){
            if(success){
                console.log("SideMenu: Vault deleted. Logging out.")
                root.logoutClicked()
            }
        }
    }

    // Αυτό πιάνει το σήμα από το Watchtower
    Connections {
        target: stack.currentItem 
        ignoreUnknownSignals: true 

        function onRequestEditPassword(id) {
            console.log("Global Signal: Opening edit for ID:", id)
            root.openEditPopup(id)
        }
    }

    // ΤΟ POPUP - Χρησιμοποιoύμε το ίδιο με το PasswordsPage
    ViewPasswordPopUp {
        id: viewPasswordPopUp
        
        // Signal handler for when operation finishes (add/update)
        Connections {
            target: vaultBackend
            function onOperation_finished(success, message) {
                if (success && viewPasswordPopUp.visible) {
                    console.log("WatchTower Edit: Save successful, refreshing page...")
                    viewPasswordPopUp.close()
                    root.updatePage() // Refresh WatchTower page
                }
            }
        }
    }

    // ΣΥΝΑΡΤΗΣΗ ΠΟΥ ΦΕΡΝΕΙ ΤΑ ΔΕΔΟΜΕΝΑ
    function openEditPopup(passId) {
        console.log("Fetching details from Python for passId:", passId)
        var details = vaultBackend.get_decrypted_password(root.userIdString, passId)
        
        if (details.success) {
            // Set edit mode
            viewPasswordPopUp.isAdding = false
            viewPasswordPopUp.isEditing = true
            
            // Set data
            viewPasswordPopUp.itemId = passId
            viewPasswordPopUp.userId = root.userIdString
            viewPasswordPopUp.masterPassword = root.masterPassword
            viewPasswordPopUp.titleText = details.title || ""
            viewPasswordPopUp.usernameText = details.username || ""
            viewPasswordPopUp.passwordText = details.password || ""
            viewPasswordPopUp.websiteText = details.website || ""
            viewPasswordPopUp.noteText = details.note || ""
            viewPasswordPopUp.createdText = details.created_at || ""
            viewPasswordPopUp.lastModifiedText = details.last_modified || ""
            viewPasswordPopUp.hasTotp = details.has_totp || false
            viewPasswordPopUp.totpCode = details.totp_code || ""
            
            viewPasswordPopUp.populateFields()
            viewPasswordPopUp.show()
        } else {
            console.error("Error fetching data:", details.message)
        }
    }

    // UPDATE PAGE
    function updatePage() {
        var page;
        var props = {};
        // Κοινά props
        var commonProps = {"userId": root.userIdString, "masterPassword": root.masterPassword};

        switch(currentPage){
            case "passwords": 
                page = "PasswordsPage.qml"; 
                props = commonProps; 
                break;
            case "cards":
                page = "CardsPage.qml";
                props = commonProps;
                break;
            case "watchTower": 
                page = "WatchTowerPage.qml"; 
                props = commonProps; 
                break;
            case "generator": page = "GeneratorPage.qml"; break;
            case "settings": 
                page = "SettingsPage.qml"; 
                props = {"userId": root.userIdString};
                break;
        }
        if(page) stack.replace(page, props);
    }

    //  UI VISUALS
    Rectangle {
        color: "#1E2634"
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            // Side Bar
            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                color: "#303946"
                radius: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Logo Area
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        Image {
                            id: gkip_logo
                            Layout.preferredWidth: 70; Layout.preferredHeight: 70
                            source: "../imgs/gkip_logo.png"
                            Layout.topMargin: 30
                            fillMode: Image.PreserveAspectFit
                        }
                        ColumnLayout {
                            Label { text: "GKIP"; color: "white"; font.pointSize: 24; font.bold: true }
                            Label { text: "   Password Manager"; color: "white"; font.pointSize: 12 }
                        }
                    }

                    Item { Layout.preferredHeight: 20 }

                    // Menu Buttons
                    Button {
                        id: passwordsMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/verified.png" } Text { text: "Passwords"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: currentPage === "passwords" ? "#1A222B" : (passwordsMenuButton.hovered ? "#252D36" : "#303946"); radius: 8 }
                        onClicked: { currentPage = "passwords"; updatePage(); }
                    }

                    Button {
                        id: cardsMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/cards.png" } Text { text: "Cards"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: currentPage === "cards" ? "#1A222B" : (cardsMenuButton.hovered ? "#252D36" : "#303946"); radius: 8 }
                        onClicked: { currentPage = "cards"; updatePage(); }
                    }

                    Button {
                        id: watchTowerMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/watchTower.png" } Text { text: "WatchTower"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: currentPage === "watchTower" ? "#1A222B" : (watchTowerMenuButton.hovered ? "#252D36" : "#303946"); radius: 8 }
                        onClicked: { currentPage = "watchTower"; updatePage(); }
                    }

                    Button {
                        id: generatorMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/generate.png" } Text { text: "Generator"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: currentPage === "generator" ? "#1A222B" : (generatorMenuButton.hovered ? "#252D36" : "#303946"); radius: 8 }
                        onClicked: { currentPage = "generator"; updatePage(); }
                    }

                    Button {
                        id: settingsMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/settings.png" } Text { text: "Settings"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: currentPage === "settings" ? "#1A222B" : (settingsMenuButton.hovered ? "#252D36" : "#303946"); radius: 8 }
                        onClicked: { currentPage = "settings"; updatePage(); }
                    }

                    Item {
                        Layout.preferredHeight: 170
                    }

                    /*--------White Line---------*/
                    Rectangle {
                        color: "white"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        opacity: 0.3
                    }

                    //Logout Button
                    Button {
                        id: logoutMenuButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        padding: 0

                        contentItem: Rectangle {
                            anchors.fill: parent
                            color: "transparent"

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Image {
                                    height: 25
                                    width: 25
                                    source: "../imgs/logout.png"
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    text: "Log Out"
                                    color: "white"
                                    font.pixelSize: 20
                                }
                            }
                        }

                        background: Rectangle {
                            color: logoutMenuButton.pressed ? "#353F4A" : (logoutMenuButton.hovered ? "#252D36" : "#303946")
                            radius: 8

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }
                        onClicked: {
                            root.logoutClicked()
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            /* ----------Show Pages ----------*/
            StackView {
                id: stack
                Layout.fillWidth: true
                Layout.fillHeight: true
                initialItem: PasswordsPage {
                    userId: root.userIdString
                    masterPassword: root.masterPassword
                }

                // Using Fade for the transition instead of slide
                replaceEnter: Transition {
                    OpacityAnimator {
                        from: 0
                        to: 1
                        duration: 100
                    }
                }
                replaceExit: Transition {
                    OpacityAnimator {
                        from: 1
                        to: 0
                        duration: 100
                    }
                }
            }
        }
    }
}