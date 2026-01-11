import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: passwordsPage
    width: 1300
    height: 1080

    property bool showFavorites: false
    property bool visibilityOn: false
    property string userId: ""
    property var selectedPassword: null

    property var passwordsList: []
    
    Connections {
        target: vaultBackend
        function onPasswords_updated(updatedList) {
            console.log("Passwords Page: List updated with " + updatedList.length + " items")
            passwordsPage.passwordsList = updatedList
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
                                    font.pixelSize: 16
                                    id: passwordsSearchTextField

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

                    ScrollView{
                        id: passwordItemsScrollView
                        Layout.fillHeight:true
                        Layout.fillWidth: true
                        clip: true // Ensure content doesn't overflow
                        
                        ColumnLayout {
                            width: passwordItemsScrollView.width
                            spacing: 10
                            
                            Repeater {
                                model: passwordsPage.passwordsList

                                delegate: Rectangle {
                                    id: delegateRect
                                    height: 70
                                    width: parent.width
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
                                                modelData.is_favorite = !modelData.is_favorite
                                            }    
                                        }

                                        Image{
                                            source: "https://www.google.com/s2/favicons?domain="+ modelData.Website + "&sz=40"
                                            Layout.preferredWidth: 45
                                            Layout.preferredHeight: 45

                                            onStatusChanged: {
                                                if(status === Image.Error){
                                                    source = "../imgs/placeholders/google.png"
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
                            }
                        }
                    }

                }

                /*--------------Details----------------*/
                Rectangle{
                    Layout.preferredWidth:450
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
                                        source:  selectedPassword? "https://www.google.com/s2/favicons?domain="+ selectedPassword.Website + "&sz=60" : "../imgs/placeholders/google.png"
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true

                                         onStatusChanged: {
                                                if(status === Image.Error){
                                                    source = "../imgs/placeholders/google.png"
                                                }
                                            }
                                            
                                        }

                                        ColumnLayout{

                                            Label{
                                                id: detailPassNameLabel
                                                text: selectedPassword ? selectedPassword.title : "Title"
                                                font.pixelSize: 20
                                            }

                                            Label{
                                                id: detailPassLastModLabel
                                                text: selectedPassword ? selectedPassword.last_modified : "12.12.12"
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
                                            text: selectedPassword ? selectedPassword.username : "User"
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
                                            text: selectedPassword ? (visibilityOn? selectedPassword.password : "**********") : (visibilityOn? "1234567890" : "**********")
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
                                            text: selectedPassword ? selectedPassword.website : "www.website.com"
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
                            Layout.preferredHeight: 150
                            radius: 20

                            ColumnLayout{
                                anchors.topMargin: 10
                                anchors.bottomMargin: 10
                                anchors.rightMargin: 20 
                                anchors.leftMargin: 20
                                anchors.fill:parent
                                spacing: 20


                                /*--------------Last Edited Row------------*/
                                RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Last edited:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsLastEditedLabel
                                            text: "12/20/2025"
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                    }
                                /*--------------Created Row------------*/
                                RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Created:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsCreatedLabel
                                            text: "12/20/2025"
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                    }

                                /*--------------Password Updated------------*/
                                RowLayout{
                                        spacing: 10

                                        Label{
                                            text: "Password Updated:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: passDetailsUpdatedPasswordLabel
                                            text: "12/20/2025"
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
                                color: passEditButton.pressed ? "#313A4B" : (passEditButton.hovered? "#222B3A" : "#161C26" )
                                border.color: "white"

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
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
                            }
                        }

                        }
                       }
                    }
                }

            }
        }    
}
