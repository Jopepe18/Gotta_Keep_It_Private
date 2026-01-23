import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: passwordsPage
    // width: 1300  <-- Removed to allow responsive resizing
    // height: 1080 <-- Removed to allow responsive resizing
    anchors.fill: parent

    property bool showFavorites: false
    property bool visibilityOn: false
    property string userId: ""
    property string masterPassword: ""
    property var selectedPassword: null
    property string decryptedPassword: ""

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
        function onPassword_decrypted(success, password, message) {
            if (success) {
                decryptedPassword = password
                viewPasswordPopUp.passwordText = password
            } else {
                decryptedPassword = ""
                console.log("Failed to decrypt password: " + message)
                viewPasswordPopUp.passwordText = "[Decryption failed]"
            }
        }
    }

    onUserIdChanged: {
        if(passwordsPage.userId !== "") {
            console.log("PasswordsPage: userId changed to " + passwordsPage.userId + ". Fetching passwords.")
            vaultBackend.getPasswords(passwordsPage.userId)
        }
    }

    Component.onCompleted: {
        if(passwordsPage.userId !== "") {
            console.log("PasswordsPage Loaded (onCompleted). Fetching passwords for: " + passwordsPage.userId)
            vaultBackend.getPasswords(passwordsPage.userId)
        }
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
                        Layout.fillHeight: true
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
                                    source: "https://www.google.com/s2/favicons?domain="+ modelData.website + "&sz=40"
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 45

                                    onStatusChanged: {
                                        if(status === Image.Error){
                                            source = "../imgs/placeholders/default_image.png"
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
                                        Layout.preferredHeight: 60
                                        Layout.preferredWidth: 60
                                        source:  selectedPassword ? ("https://www.google.com/s2/favicons?domain="+ selectedPassword.website + "&sz=40") : "../imgs/placeholders/default_image.png"
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true

                                         onStatusChanged: {
                                                if(status === Image.Error){
                                                    source = "../imgs/placeholders/default_image.png"
                                                }
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

                                        Label{
                                            id: passDetailsPasswordLabel
                                            text: selectedPassword ?
                                             (visibilityOn ? decryptedPassword : "**********") 
                                             : "******"
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }

                                        Button{
                                            id: changePasswordVisibilityButton
                                            background: Rectangle{
                                                color: "transparent"
                                            }

                                            contentItem: Image{
                                            height: 30
                                            width: 30 
                                            source: visibilityOn ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                            }

                                            onClicked:{
                                                if(!selectedPassword) return
                                                visibilityOn = !visibilityOn
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

                                        Image{
                                            id: passSafetyImage
                                            Layout.preferredHeight: 30
                                            Layout.preferredWidth: 30
                                            source: "../imgs/safe.png"
                                        }
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }

                                /*----------------Add a Note Text Field---------------*/
                                TextField{
                                    id: passAddANote
                                    placeholderText: "Add a Note..."
                                    text: selectedPassword ? selectedPassword.note : ""
                                    color: "white"

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
