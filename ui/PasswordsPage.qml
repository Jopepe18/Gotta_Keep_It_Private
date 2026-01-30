import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: passwordsPage
    anchors.fill: parent

    property bool showFavorites: false
    property bool visibilityOn: false
    property string userId: ""
    property string masterPassword: ""
    property var selectedPassword: null
    property string decryptedPassword: ""
    property string currentTotpCode: ""
    property bool hasTotp: false
    property int totpSecondsRemaining: 30

    property var passwordsList: []
    property var filteredPasswordsList: []

    // Confirmation popup for deleting password
    ConfirmationPopup {
        id: deletePasswordConfirmation
        titleText: "Delete Password"
        messageText: "Are you sure you want to delete this password? This action cannot be undone."
        confirmButtonText: "Delete"
        onConfirmed: {
            if (passwordsPage.selectedPassword) {
                console.log("Deleting password ID: " + passwordsPage.selectedPassword.id)
                vaultBackend.deletePassword(passwordsPage.selectedPassword.id, passwordsPage.userId)
                passwordsPage.selectedPassword = null
            }
        }
    }
    
    Connections {
        target: vaultBackend
        function onPasswords_updated(updatedList) {
            console.log("Passwords Page: List updated with " + updatedList.length + " items")
            passwordsPage.passwordsList = updatedList
            filterPasswords()
        }
        function onPassword_decrypted(success, password, message, totpCode, hasTotpFlag) {
            if (success) {
                decryptedPassword = password
                viewPasswordPopUp.passwordText = password
                currentTotpCode = totpCode
                hasTotp = hasTotpFlag
                viewPasswordPopUp.totpCode = totpCode
                viewPasswordPopUp.hasTotp = hasTotpFlag
                // Start TOTP countdown if has TOTP
                if (hasTotpFlag) {
                    initTotpCountdown()
                } else {
                    totpRefreshTimer.stop()
                }
            } else {
                decryptedPassword = ""
                console.log("Failed to decrypt password: " + message)
                viewPasswordPopUp.passwordText = "[Decryption failed]"
                currentTotpCode = ""
                hasTotp = false
                totpRefreshTimer.stop()
            }
        }
    }
    
    // Connection to refresh passwords after Watchtower scan completes (security_status updated)
    Connections {
        target: watchTowerBackend
        function onPasswordsRefreshNeeded(userId) {
            if (userId === passwordsPage.userId) {
                console.log("PasswordsPage: Refreshing passwords after Watchtower scan")
                vaultBackend.getPasswords(passwordsPage.userId)
            }
        }
    }
    
    // Timer for TOTP countdown (every 1 second)
    Timer {
        id: totpRefreshTimer
        interval: 1000  // 1 second
        repeat: true
        running: false
        onTriggered: {
            // Calculate remaining seconds based on current time
            var now = Math.floor(Date.now() / 1000)
            passwordsPage.totpSecondsRemaining = 30 - (now % 30)
            
            // When timer reaches 0, refresh the TOTP code
            if (passwordsPage.totpSecondsRemaining === 30) {
                if (passwordsPage.selectedPassword && passwordsPage.hasTotp) {
                    console.log("TOTP refresh: requesting new code")
                    vaultBackend.decryptPassword(passwordsPage.userId, passwordsPage.selectedPassword.id)
                }
            }
        }
    }
    
    // Function to initialize TOTP countdown
    function initTotpCountdown() {
        var now = Math.floor(Date.now() / 1000)
        passwordsPage.totpSecondsRemaining = 30 - (now % 30)
        totpRefreshTimer.start()
    }

    onUserIdChanged: {
        if(passwordsPage.userId !== "") {
            console.log("PasswordsPage: userId changed to " + passwordsPage.userId + ". Fetching passwords.")
            vaultBackend.getPasswords(passwordsPage.userId)
        }
    }

    onSelectedPasswordChanged: {
        if (!selectedPassword) {
            // Clear TOTP state when deselecting
            currentTotpCode = ""
            hasTotp = false
            totpRefreshTimer.stop()
        }
    }

    Component.onCompleted: {
        if(passwordsPage.userId !== "") {
            console.log("PasswordsPage Loaded (onCompleted). Fetching passwords for: " + passwordsPage.userId)
            vaultBackend.getPasswords(passwordsPage.userId)
        }
    }

    // Helper function to extract clean domain from website URL for favicon
    function extractDomain(website) {
        if (!website || website.trim() === "") {
            return ""
        }
        var domain = website.trim()
        // Remove protocol prefixes
        domain = domain.replace(/^https?:\/\//i, "")
        // Remove www. prefix
        domain = domain.replace(/^www\./i, "")
        // Remove trailing slashes and paths
        domain = domain.split("/")[0]
        return domain
    }

    // Helper function to get favicon URL for a website
    function getFaviconUrl(website) {
        var domain = extractDomain(website)
        if (domain === "") {
            return "../imgs/placeholders/default_image.png"
        }
        return "https://www.google.com/s2/favicons?domain=" + domain + "&sz=64"
    }

    function filterPasswords()
    {
        var result = []

            // Start with all passwords
        for (var i = 0; i < passwordsList.length; i++) {
            result.push(passwordsList[i])
        }

        // Filter by favorites if showFavorites is enabled
        if (showFavorites) {
            result = result.filter(function(item) {
                return item.is_favorite === true
            })
        }

        // Filter by search text
        if (passwordsSearchTextField.text && passwordsSearchTextField.text.trim() !== "") {
            var query = passwordsSearchTextField.text.toLowerCase()
            result = result.filter(function(item) {
                return (item.title && item.title.toLowerCase().includes(query))
            })
        }

        // Reassign to trigger binding update
        filteredPasswordsList = result
    }

    RowLayout{
        anchors.fill: parent
        spacing: 0

        Rectangle{
            color: "#1E2634"
            Layout.fillHeight:true
            Layout.fillWidth:true

            RowLayout{
                anchors.fill: parent
                spacing:10

                /*---------All Passwords-----------*/
                ColumnLayout{
                    Layout.preferredWidth: 800
                    Layout.fillHeight: true
                    Layout.margins: 30
                    spacing: 40

                    Label{
                        text:"All Passwords"
                        color: "white"
                        font.pointSize: 28
                        
                    }

                    /*----------Search TextField and Buttons*/
                    RowLayout{
                        spacing: 20

                        /*----------Search TextField----------*/

                        Rectangle{
                            width: 300
                            height: 45
                            color: "#1E2634"
                            border.color: "white"
                            border.width: 2
                            radius: 8


                            RowLayout{
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10


                                Image{
                                    Layout.preferredWidth: 20 
                                    Layout.preferredHeight: 20
                                    source: "../imgs/search.png"
                                    fillMode: Image.PreserveAspectFit
                                }

                                TextField{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    placeholderText: "Search..."
                                    color: "white"
                                    font.pixelSize: 14
                                    id: passwordsSearchTextField
                                    onTextChanged: filterPasswords()

                                    background: Rectangle{
                                        color: "transparent"
                                    }
                                }
                            }
                        }

                        /*------------Show Favorites Button-----------*/
                        Button{
                            id: showFavoritePasswordsButton
                            Layout.preferredWidth:170
                            Layout.preferredHeight:45
                            padding:0

                            contentItem: Rectangle{
                                anchors.fill: parent
                                color: "transparent"

                                Row{
                                    anchors.centerIn:parent
                                    spacing:5

                                    Image{
                                        height:24
                                        width:24
                                        source: showFavorites ? "../imgs/favorite.png" : "../imgs/not_favoriteStar.png"
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    Text{
                                        text: "Favorites"
                                        color: "white"
                                        font.pixelSize:20
                                    }
                                }
                            }

                            background: Rectangle{
                                radius:20
                                color: showFavoritePasswordsButton.pressed ? "#20B990" : (showFavoritePasswordsButton.hovered? "#109C77" : "#09946D" )

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }

                            onClicked:{
                                showFavorites = !showFavorites
                                filterPasswords()
                            }
                        }

                        /*------------Add New Password Button-----------*/
                        Button{
                            id: addNewPasswordButton
                            Layout.preferredWidth:150
                            Layout.preferredHeight:45
                            padding:0

                            contentItem: Rectangle{
                                anchors.fill: parent
                                color: "transparent"

                                Row{
                                    anchors.centerIn:parent
                                    spacing:5

                                    Image{
                                        height:25
                                        width:25
                                        source: "../imgs/add.png"
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    Text{
                                        text: "New"
                                        color: "white"
                                        font.pixelSize:20
                                    }
                                }

                                
                            }

                            background: Rectangle{
                                radius:20
                                color: addNewPasswordButton.pressed ? "#5093E9" : (addNewPasswordButton.hovered? "#3E82DB" : "#2F72CA" )

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }
                            onClicked: {
                                // Open PopUp in ADD mode
                                viewPasswordPopUp.isAdding = true
                                viewPasswordPopUp.isEditing = false
                                viewPasswordPopUp.userId = passwordsPage.userId
                                viewPasswordPopUp.masterPassword = passwordsPage.masterPassword
                                
                                // Reset fields logic
                                viewPasswordPopUp.resetFields()
                                viewPasswordPopUp.itemId = -1
                                
                                viewPasswordPopUp.show()
                            }
                        }

                        /*------------DEBUG Button-----------*/
                        Button{
                            id: addPasswordDebug
                            Layout.preferredWidth:150
                            Layout.preferredHeight:45
                            padding:0
                            text: "Debug Add"
                            visible: false
                            
                            contentItem: Text {
                                text: addPasswordDebug.text
                                color: "white"
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle{
                                radius:20
                                color: "#FF5500" // Orange for debug
                            }
                             onClicked: {
                                    console.log("Debug Add Clicked for User: " + passwordsPage.userId)
                                    vaultBackend.addDebugPassword(passwordsPage.userId)
                             }
                        }


                    }

                    /*----------Headline-------------*/
                    ColumnLayout{
                        spacing: 10

                        RowLayout{
                        Layout.leftMargin: 25
                        spacing:100

                        Label{
                            text:"Favorite"
                            color: "#ACACAC"
                            font.pointSize:17
                        }

                        Label{
                            text:"Name"
                            color: "#ACACAC"
                            font.pointSize:17
                        }
                    }

                    Rectangle{
                            color: "#ACACAC"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            opacity: 0.3
                        }
                    }

                    ListView {
                        id: passwordListView
                        Layout.preferredHeight: 470
                        Layout.fillWidth: true
                        clip: true
                        spacing: 10
                        model: passwordsPage.filteredPasswordsList

                        delegate: Rectangle {
                            id: delegateRect
                            height: 70
                            width: passwordListView.width // Use ListView width
                            radius: 10

                            property bool selected: false
                            property bool hovered: false

                            color: (selectedPassword && selectedPassword.id === modelData.id) ? "#111B2C" : 
                            (selected ? "#424D61" : 
                                hovered ? "#2A3444" : "#1E2634")
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: delegateRect.hovered = true
                                onExited: delegateRect.hovered = false
                                onPressed: delegateRect.selected = true
                                onReleased: delegateRect.selected = false
                                onClicked:{
                                    passwordsPage.selectedPassword = modelData
                                    console.log("Selected password: ", modelData.title)
                                     // Request password decryption
                                    vaultBackend.decryptPassword(passwordsPage.userId, modelData.id)
                                }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 30
                                anchors.topMargin: 10
                                anchors.bottomMargin: 10
                                spacing: 45
                                
                                Button{
                                    Layout.preferredHeight: 40
                                    Layout.preferredWidth: 40
                                    background: Rectangle{
                                        color: "transparent"
                                    }

                                    contentItem: Image {
                                        source: modelData.is_favorite ? "../imgs/favorite.png" : "../imgs/not_favoriteStar.png"
                                        width: 20
                                        height: 20
                                    }
                                    onClicked:{
                                        var newFavoriteStatus = !modelData.is_favorite

                                        vaultBackend.setFavorite(
                                            passwordsPage.userId,
                                            modelData.id,
                                            newFavoriteStatus
                                        )

                                        var updatedList = []
                                        for (var i = 0; i < passwordsList.length; i++) {
                                            if (passwordsList[i].id === modelData.id) {
                                                // Create a new object with updated favorite status
                                                var updatedItem = Object.assign({}, passwordsList[i])
                                                updatedItem.is_favorite = newFavoriteStatus
                                                updatedList.push(updatedItem)
                                            } else {
                                                updatedList.push(passwordsList[i])
                                            }
                                        }
                                        
                                        // Reassign the entire array to trigger property binding
                                        passwordsPage.passwordsList = updatedList

                                        // Refresh filter in case we're in favorites mode
                                        filterPasswords()
                                    }    
                                }

                                Image{
                                    id: listFaviconImage
                                    property bool hasError: false
                                    source: hasError ? "../imgs/placeholders/default_image.png" : getFaviconUrl(modelData.website)
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 45
                                    asynchronous: true  
                                    cache: true
                                    onStatusChanged: {
                                        if(status === Image.Error){
                                            hasError = true
                                        }
                                    }
                                }
                                
                                ColumnLayout{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    // Title
                                    Text {
                                        text: modelData.title
                                        color: "white"
                                        font.pixelSize: 18
                                        Layout.fillWidth: true
                                    }
                                    
                                    // Updates
                                    Text {
                                        text: modelData.username
                                        color: "#B5B5B5"
                                        font.pixelSize: 14
                                    }
                                }
                            }
                        }
                        
                        footer: Item {
                            height: 50
                        }
                    }

                    Item{
                        Layout.fillHeight: true
                    }

                }

                /*--------------Details----------------*/
                Rectangle{
                    Layout.preferredWidth:400
                    Layout.fillHeight: true
                    color: "#161C26"
                    radius: 20

                    ColumnLayout{
                        Layout.fillHeight:true

                       ColumnLayout{
                        Layout.margins: 20
                        Layout.fillWidth: true

                        Label{
                        text:"Details"
                        color: "white"
                        font.pointSize: 20
                        }

                        Rectangle{
                            color: "#303946"
                            Layout.preferredWidth: 360
                            Layout.preferredHeight:370
                            radius: 20

                            ColumnLayout{
                                anchors.margins: 20
                                anchors.fill:parent

                                /*------------Image Title and Last Modification Labels*/
                                RowLayout{
                                    spacing: 20
                                    Layout.topMargin: 10
                                    Layout.leftMargin: 20
                                    Layout.rightMargin: 20
                                    Layout.bottomMargin: 20
                                    Layout.fillWidth: true

                                        Image{
                                        id: detailImage
                                        property bool hasError: false
                                        property var currentPasswordId: selectedPassword ? selectedPassword.id : null
                                        Layout.preferredHeight: 60
                                        Layout.preferredWidth: 60
                                        source: hasError ? "../imgs/placeholders/default_image.png" : 
                                                (selectedPassword ? getFaviconUrl(selectedPassword.website) : "../imgs/placeholders/default_image.png")
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true

                                        onStatusChanged: {
                                            if(status === Image.Error){
                                                hasError = true
                                            }
                                        }
                                        
                                        onCurrentPasswordIdChanged: {
                                            hasError = false
                                        }
                                        }

                                        ColumnLayout{

                                            Label{
                                                id: detailPassNameLabel
                                                text: selectedPassword ? selectedPassword.title : " "
                                                font.pixelSize: 20
                                            }

                                            Label{
                                                id: detailPassLastModLabel
                                                text: selectedPassword ? selectedPassword.last_modified : " "
                                                color: "#B5B5B5"
                                                font.pixelSize: 16
                                            }
                                        }
                                }
                                
                                /*-------Details of Object*/
                               ColumnLayout{
                                spacing: 10

                                 /*----------Username Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Username"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsUsernameLabel
                                            text: selectedPassword ? selectedPassword.username : " "
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                        
                                        // Copy username button
                                        Button{
                                            id: copyUsernameButton
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                            
                                            background: Rectangle{
                                                color: copyUsernameButton.hovered ? "#3d4a5c" : "transparent"
                                                radius: 6
                                            }

                                            contentItem: Text {
                                                text: "📋"
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                opacity: copyUsernameButton.hovered ? 1.0 : 0.6
                                            }
                                            
                                            ToolTip.visible: hovered
                                            ToolTip.delay: 300
                                            ToolTip.text: "Copy username"

                                            onClicked:{
                                                if(!selectedPassword || !selectedPassword.username) return
                                                usernameCopyHelper.text = selectedPassword.username
                                                usernameCopyHelper.selectAll()
                                                usernameCopyHelper.copy()
                                                console.log("Username copied to clipboard")
                                                usernameCopiedLabel.visible = true
                                                usernameCopiedTimer.start()
                                            }
                                        }
                                        
                                        TextField {
                                            id: usernameCopyHelper
                                            visible: false
                                        }
                                    }
                                    
                                    // Username copy feedback
                                    Label {
                                        id: usernameCopiedLabel
                                        text: "✓ Copied!"
                                        color: "#27ae60"
                                        font.pixelSize: 11
                                        visible: false
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    
                                    Timer {
                                        id: usernameCopiedTimer
                                        interval: 1500
                                        onTriggered: usernameCopiedLabel.visible = false
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }


                                /*----------Password Row---------------*/
                                ColumnLayout{
                                    spacing: 5

                                    RowLayout{
                                        spacing: 0
                                        Layout.fillWidth:true

                                        Label{
                                            text: "Password"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        // Password with hover-to-reveal
                                        Rectangle {
                                            id: passwordRevealArea
                                            Layout.preferredWidth: passwordTextLabel.implicitWidth + 10
                                            Layout.preferredHeight: 25
                                            color: passwordHoverArea.containsMouse ? "#3d4a5c" : "transparent"
                                            radius: 5
                                            
                                            property bool isHovered: passwordHoverArea.containsMouse
                                            
                                            Label{
                                                id: passwordTextLabel
                                                anchors.centerIn: parent
                                                text: selectedPassword ?
                                                    (passwordRevealArea.isHovered ? decryptedPassword : "••••••••••") 
                                                    : "••••••••••"
                                                color: passwordRevealArea.isHovered ? "#5093E9" : "#B5B5B5"
                                                font.pixelSize: 15
                                                font.family: passwordRevealArea.isHovered ? "Menlo" : undefined
                                            }
                                            
                                            MouseArea {
                                                id: passwordHoverArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                
                                                ToolTip.visible: containsMouse && selectedPassword
                                                ToolTip.delay: 500
                                                ToolTip.text: "Hover to reveal password"
                                            }
                                        }

                                        // Copy button (subtle icon)
                                        Button{
                                            id: copyPasswordButton
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                            
                                            background: Rectangle{
                                                color: copyPasswordButton.hovered ? "#3d4a5c" : "transparent"
                                                radius: 6
                                            }

                                            contentItem: Text {
                                                text: "📋"
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                opacity: copyPasswordButton.hovered ? 1.0 : 0.6
                                            }
                                            
                                            ToolTip.visible: hovered
                                            ToolTip.delay: 300
                                            ToolTip.text: "Copy password"

                                            onClicked:{
                                                if(!selectedPassword || !decryptedPassword) return
                                                passCopyHelper.text = decryptedPassword
                                                passCopyHelper.selectAll()
                                                passCopyHelper.copy()
                                                console.log("Password copied to clipboard")
                                                // Brief visual feedback
                                                copyFeedbackLabel.visible = true
                                                copyFeedbackTimer.start()
                                            }
                                        }
                                        
                                        // Hidden helper for clipboard
                                        TextField {
                                            id: passCopyHelper
                                            visible: false
                                        }
                                    }
                                    
                                    // Copy feedback label
                                    Label {
                                        id: copyFeedbackLabel
                                        text: "✓ Copied!"
                                        color: "#27ae60"
                                        font.pixelSize: 11
                                        visible: false
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    
                                    Timer {
                                        id: copyFeedbackTimer
                                        interval: 1500
                                        onTriggered: copyFeedbackLabel.visible = false
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }
                                
                                /*----------Website Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Website"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Label{
                                            id: passDetailsWebsiteLabel
                                            text: selectedPassword ? selectedPassword.website : " "
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                        
                                        // Copy website button
                                        Button{
                                            id: copyWebsiteButton
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 28
                                            
                                            background: Rectangle{
                                                color: copyWebsiteButton.hovered ? "#3d4a5c" : "transparent"
                                                radius: 6
                                            }

                                            contentItem: Text {
                                                text: "📋"
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                opacity: copyWebsiteButton.hovered ? 1.0 : 0.6
                                            }
                                            
                                            ToolTip.visible: hovered
                                            ToolTip.delay: 300
                                            ToolTip.text: "Copy website"

                                            onClicked:{
                                                if(!selectedPassword || !selectedPassword.website) return
                                                websiteCopyHelper.text = selectedPassword.website
                                                websiteCopyHelper.selectAll()
                                                websiteCopyHelper.copy()
                                                console.log("Website copied to clipboard")
                                                websiteCopiedLabel.visible = true
                                                websiteCopiedTimer.start()
                                            }
                                        }
                                        
                                        TextField {
                                            id: websiteCopyHelper
                                            visible: false
                                        }
                                    }
                                    
                                    // Website copy feedback
                                    Label {
                                        id: websiteCopiedLabel
                                        text: "✓ Copied!"
                                        color: "#27ae60"
                                        font.pixelSize: 11
                                        visible: false
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    
                                    Timer {
                                        id: websiteCopiedTimer
                                        interval: 1500
                                        onTriggered: websiteCopiedLabel.visible = false
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }


                                /*----------Safety Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Safety"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Image {
                                           id: passSafetyImage
                                           // BREACHED icon has more padding, so we make it larger
                                           property bool isBreached: selectedPassword && selectedPassword.security_status === "BREACHED"
                                           Layout.preferredHeight: isBreached ? 45 : 30
                                           Layout.preferredWidth: isBreached ? 45 : 30
                                           sourceSize.width: isBreached ? 45 : 30
                                           sourceSize.height: isBreached ? 45 : 30
                                           fillMode: Image.PreserveAspectFit
                                        
                                           source: {
                                            if (!selectedPassword) return "../imgs/verified.png" 
                                            console.log("Current Status for " + selectedPassword.title + ": " + selectedPassword.security_status)
                                            switch (selectedPassword.security_status) {
                                                case "BREACHED": 
                                                    return "../imgs/broken_shield.png" 
                                                case "WEAK": 
                                                    return "../imgs/warning.png" 
                                                case "REUSED": 
                                                    return "../imgs/warning.png"
                                                case "SAFE": 
                                                    return "../imgs/safe.png"
                                                default: 
                                                    return "../imgs/verified.png" 
                                            }
                                           }
                                        }
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }

                                /*----------------Note Display (Read-Only)---------------*/
                                TextField{
                                    id: passAddANote
                                    placeholderText: "No note"
                                    text: selectedPassword ? selectedPassword.note : ""
                                    color: "#B5B5B5"
                                    readOnly: true
                                    
                                    background: Rectangle{
                                        color: "#303946"
                                    }
                                }

                                Item{
                                    Layout.fillHeight: true
                                }

                                }
                                
                            }
                        }

                        /*----------------TOTP Section (2FA)---------------*/
                        Rectangle {
                            color: "#303946"
                            Layout.preferredWidth: 360
                            Layout.preferredHeight: 90
                            radius: 20
                            visible: passwordsPage.hasTotp
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 12
                                
                                // Circular countdown timer
                                Rectangle {
                                    id: countdownCircle
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 50
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 25
                                    color: "transparent"
                                    border.color: "#444"
                                    border.width: 3
                                    
                                    // Progress arc (using Canvas)
                                    Canvas {
                                        id: progressCanvas
                                        anchors.fill: parent
                                        property real progress: passwordsPage.totpSecondsRemaining / 30.0
                                        
                                        onProgressChanged: requestPaint()
                                        
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.reset()
                                            
                                            var centerX = width / 2
                                            var centerY = height / 2
                                            var radius = (width - 6) / 2
                                            
                                            // Draw progress arc
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress), false)
                                            ctx.strokeStyle = progress > 0.2 ? "#5093E9" : "#F76262"  // Red when low
                                            ctx.lineWidth = 3
                                            ctx.stroke()
                                        }
                                    }
                                    
                                    // Seconds text in center
                                    Label {
                                        anchors.centerIn: parent
                                        text: passwordsPage.totpSecondsRemaining
                                        color: passwordsPage.totpSecondsRemaining <= 5 ? "#F76262" : "#5093E9"
                                        font.pointSize: 14
                                        font.bold: true
                                    }
                                }
                                
                                // Code display
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    
                                    Label { 
                                        text: "2FA Code"
                                        color: "#7B7B7B"
                                        font.pointSize: 11
                                    }
                                    
                                    Label { 
                                        id: totpCodeLabel
                                        text: passwordsPage.currentTotpCode || "------"
                                        color: passwordsPage.totpSecondsRemaining <= 5 ? "#F76262" : "#5093E9"
                                        font.pointSize: 22
                                        font.bold: true
                                        font.family: "Menlo"
                                    }
                                }
                                
                                Button {
                                    Layout.preferredWidth: 65
                                    Layout.preferredHeight: 35
                                    Layout.alignment: Qt.AlignVCenter
                                    background: Rectangle { color: "#5093E9"; radius: 10 }
                                    contentItem: Text { 
                                        text: "Copy"
                                        color: "white"
                                        font.pointSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter 
                                    }
                                    onClicked: {
                                        if (passwordsPage.currentTotpCode) {
                                            totpCopyField.text = passwordsPage.currentTotpCode
                                            totpCopyField.selectAll()
                                            totpCopyField.copy()
                                            console.log("TOTP code copied")
                                        }
                                    }
                                }
                            }
                            
                            // Hidden helper for copy
                            TextField {
                                id: totpCopyField
                                visible: false
                            }
                        }

                        Item{
                            Layout.preferredHeight: 10
                        }

                        Label{
                            text: "Item history"
                            color: "white"
                            font.pointSize:18
                        }

                        /*Item History Details*/
                        Rectangle{
                            color: "#303946"
                            Layout.preferredWidth: 360
                            Layout.preferredHeight: 90
                            radius: 20

                            ColumnLayout{
                                anchors.topMargin: 10
                                anchors.bottomMargin: 10
                                anchors.rightMargin: 20 
                                anchors.leftMargin: 20
                                anchors.fill:parent
                                spacing: 15

                                /*--------------Created Row------------*/
                                RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Created at:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsCreatedLabel
                                            text: (selectedPassword && selectedPassword.created_at) ? selectedPassword.created_at : ""
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                    }

                                /*--------------Last Modified------------*/
                                RowLayout{
                                        spacing: 10

                                        Label{
                                            text: "Last Modified:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsUpdatedPasswordLabel
                                            text: (selectedPassword && selectedPassword.last_modified) ? selectedPassword.last_modified : ""
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }

                                    }

                              
        
                            }
                        }

                        Item{
                            Layout.fillHeight:true
                        }
                        

                        RowLayout{
                            Layout.margins:20

                            Button{
                                id: passEditButton
                                text: "Edit"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth: 85

                             background: Rectangle{
                                radius:20
                                color: passEditButton.pressed ? "#5093E9" : (passEditButton.hovered? "#3E82DB" : "#2F72CA" )
                                // border.color: "white" // Removed border for cleaner look, or keep if preferred. User asked for color diff.
                                
                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                                }

                                onClicked:{
                                    // Open View Popup
                                    viewPasswordPopUp.isAdding = false
                                    viewPasswordPopUp.isEditing = true
                                    viewPasswordPopUp.itemId = selectedPassword.id
                                    viewPasswordPopUp.userId = passwordsPage.userId
                                    viewPasswordPopUp.masterPassword = passwordsPage.masterPassword
                                    viewPasswordPopUp.titleText = selectedPassword.title || ""
                                    viewPasswordPopUp.usernameText = selectedPassword.username || ""
                                    // viewPasswordPopUp.passwordText = "Loading..."  // Removed to avoid overwriting if already decrypted? No, we need to show loading or fetch it.
                                    // Actually, let's keep it as is, but we need to ensure the field is populated.
                                    viewPasswordPopUp.passwordText = "Loading..." 
                                    viewPasswordPopUp.websiteText = selectedPassword.website || ""
                                    viewPasswordPopUp.noteText = selectedPassword.note || ""
                                    viewPasswordPopUp.createdText = selectedPassword.created_at || ""
                                    viewPasswordPopUp.lastModifiedText = selectedPassword.last_modified || ""
                                    viewPasswordPopUp.populateFields() // Explicitly populate fields
                                    viewPasswordPopUp.show()
                                    
                                    // Request password decryption
                                    vaultBackend.decryptPassword(passwordsPage.userId, selectedPassword.id)
                                }
                            }


                            Item{
                                Layout.fillWidth: true
                            }

                            Button{
                                id: passDeleteButton
                                text: "Delete"
                                font.pixelSize: 17
                                Layout.preferredHeight: 45
                                Layout.preferredWidth:85

                             background: Rectangle{
                                radius:20
                                color: passDeleteButton.pressed ? "#F76262" : (passDeleteButton.hovered? "#F54040" : "#E22323" )

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }

                            onClicked: {
                                if (passwordsPage.selectedPassword) {
                                    deletePasswordConfirmation.open()
                                }
                            }
                            }
                        }

                        }
                       }
                    }
                }

            }
        }

    
    ViewPasswordPopUp {
        id: viewPasswordPopUp
    }    
}