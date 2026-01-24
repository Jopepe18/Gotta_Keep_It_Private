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

    // 1. ΣΥΝΔΕΣΗ ΜΕ ΤΗ ΒΑΣΗ (ΓΙΑ LOGOUT)
    Connections {
        target: vaultBackend
        function onVaultDeleted(success, message){
            if(success){
                console.log("SideMenu: Vault deleted. Logging out.")
                root.logoutClicked()
            }
        }
    }

    // 2. ΣΥΝΔΕΣΗ ΜΕ ΤΙΣ ΣΕΛΙΔΕΣ (ΓΙΑ ΤΟ ΚΛΙΚ)
    // Αυτό πιάνει το σήμα από το Watchtower
    Connections {
        target: stack.currentItem 
        ignoreUnknownSignals: true 

        function onRequestEditPassword(id) {
            console.log("Global Signal: Opening edit for ID:", id)
            root.openEditPopup(id)
        }
    }

    // 3. ΤΟ POPUP (ΤΟ ΠΑΡΑΘΥΡΟ)
    EditPasswordPopup {
        id: editPasswordPopup // Μικρό 'e' στο ID
        
        onUpdateRequested: (id, title, username, password, website, note) => {
            console.log("Saving changes for ID:", id)
            var result = vaultBackend.update_password(root.userIdString, id, root.masterPassword, {
                "title": title, "username": username, "password": password, "website": website, "note": note
            })
            
            if (result.success) {
                root.updatePage() // Ανανέωση της σελίδας
            } else {
                console.error("Update error:", result.message)
            }
        }
    }

    // 4. ΣΥΝΑΡΤΗΣΗ ΠΟΥ ΦΕΡΝΕΙ ΤΑ ΔΕΔΟΜΕΝΑ
    function openEditPopup(passId) {
        console.log("Fetching details from Python...")
        var details = vaultBackend.get_decrypted_password(root.userIdString, passId)
        
        if (details.success) {
            editPasswordPopup.itemId = details.id
            editPasswordPopup.titleText = details.title || ""
            editPasswordPopup.usernameText = details.username || ""
            editPasswordPopup.passwordText = details.password || ""
            editPasswordPopup.websiteText = details.website || ""
            editPasswordPopup.noteText = details.note || ""
            
            editPasswordPopup.show()
        } else {
            console.error("Error fetching data:", details.message)
        }
    }

    // 5. UPDATE PAGE
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

    // 6. UI VISUALS
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

                    Item { Layout.fillHeight: true }

                    // Logout
                    Button {
                        id: logoutMenuButton
                        Layout.fillWidth: true; Layout.preferredHeight: 55; padding: 0
                        contentItem: Rectangle { color: "transparent"; Row { anchors.centerIn: parent; spacing: 5; Image { height: 25; width: 25; source: "../imgs/logout.png" } Text { text: "Log Out"; color: "white"; font.pixelSize: 20 } } }
                        background: Rectangle { color: logoutMenuButton.hovered ? "#252D36" : "#303946"; radius: 8 }
                        onClicked: { root.logoutClicked() }
                    }
                    Item { Layout.preferredHeight: 20 }
                }
            }

            // Main Content Area
            Component {
                id: firstPasswordPage
                PasswordsPage {
                    userId: root.userIdString
                    masterPassword: root.masterPassword
                }
            }

            StackView {
                id: stack
                Layout.fillWidth: true
                Layout.fillHeight: true
                initialItem: firstPasswordPage
                replaceEnter: Transition { OpacityAnimator { from: 0; to: 1; duration: 100 } }
                replaceExit: Transition { OpacityAnimator { from: 1; to: 0; duration: 100 } }
            }
        }
    }
}