import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: cardsPage
    width: 1300
    height: 800

    property bool showFavorites: false
    property bool cvvVisibilityOn: false
    property bool cardNumberVisibilityOn: false
    property string userId: ""
    property string masterPassword: ""
    property var selectedCard: null
    property string decryptedCardNumber: ""
    property string decryptedCvv: ""

    property var cardsList: []
    property var filteredCardsList: []

    // Popup for adding new card
    AddCardPopup {
        id: addCardPopup
        onSaved: function(title, holder, number, cvv, expiry, pin, type, note) {
            console.log("Adding card: " + title)
            vaultBackend.addCard(
                cardsPage.userId,
                cardsPage.masterPassword,
                title,
                holder,
                number,
                cvv,
                type,
                expiry,
                note
            )
        }
    }

    // Popup for editing card
    EditCardPopup {
        id: editCardPopup
        onUpdated: function(cardId, title, holder, number, cvv, expiry, type, note) {
            console.log("Updating card: " + cardId)
            vaultBackend.updateCard(
                cardsPage.userId,
                cardId,
                cardsPage.masterPassword,
                title,
                holder,
                number,
                cvv,
                type,
                expiry,
                note
            )
        }
        onDeleted: function(cardId) {
            console.log("Deleting card from popup: " + cardId)
            vaultBackend.deleteCard(cardId, cardsPage.userId)
            cardsPage.selectedCard = null
        }
    }

    // Confirmation popup for deleting card
    ConfirmationPopup {
        id: deleteCardConfirmation
        titleText: "Delete Card"
        messageText: "Are you sure you want to delete this card? This action cannot be undone."
        confirmButtonText: "Delete"
        onConfirmed: {
            if (selectedCard) {
                console.log("Deleting card ID: " + selectedCard.id)
                vaultBackend.deleteCard(selectedCard.id, cardsPage.userId)
                cardsPage.selectedCard = null
            }
        }
    }

    Connections {
        target: vaultBackend
        function onCards_updated(updatedList) {
            console.log("Cards Page: List updated with " + updatedList.length + " items")
            cardsPage.cardsList = updatedList
            filterCards()
        }
        function onCard_decrypted(success, card, message) {
            if (success) {
                decryptedCardNumber = card.card_number
                decryptedCvv = card.cvv
            } else {
                decryptedCardNumber = ""
                decryptedCvv = ""
                console.log("Failed to decrypt card: " + message)
            }
        }
    }

    onUserIdChanged: {
        if(cardsPage.userId !== "") {
            console.log("CardsPage: userId changed to " + cardsPage.userId + ". Fetching cards.")
            vaultBackend.getCards(cardsPage.userId)
        }
    }

    Component.onCompleted: {
        if(cardsPage.userId !== "") {
            console.log("CardsPage Loaded (onCompleted). Fetching cards for: " + cardsPage.userId)
            vaultBackend.getCards(cardsPage.userId)
        }
    }

    function filterCards()
    {
        var result = []

            // Start with all passwords
        for (var i = 0; i < cardsList.length; i++) {
            result.push(cardsList[i])
        }

        // Filter by favorites if showFavorites is enabled
        if (showFavorites) {
            result = result.filter(function(item) {
                return item.is_favorite === true
            })
        }

        // Filter by search text
        if (cardsSearchTextField.text && cardsSearchTextField.text.trim() !== "") {
            var query = cardsSearchTextField.text.toLowerCase()
            result = result.filter(function(item) {
                return (item.title && item.title.toLowerCase().includes(query))
            })
        }

        // Reassign to trigger binding update
        filteredCardsList = result
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

                /*---------All Cards-----------*/
                ColumnLayout{
                    Layout.preferredWidth: 800
                    Layout.fillHeight: true
                    Layout.margins: 30
                    spacing: 40

                    Label{
                        text:"All Credit/Debit Cards"
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
                                    id: cardsSearchTextField

                                    background: Rectangle{
                                        color: "transparent"
                                    }

                                    onTextChanged: filterCards()
                                }
                            }
                        }

                        /*------------Show Favorites Button-----------*/
                        Button{
                            id: showFavoriteCardsButton
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
                                color: showFavoriteCardsButton.pressed ? "#20B990" : (showFavoriteCardsButton.hovered? "#109C77" : "#09946D" )

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }

                            onClicked:{
                                showFavorites = !showFavorites
                                filterCards()
                            }

                        }

                        /*------------Add New Card Button-----------*/
                        Button{
                            id: addNewCardButton
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
                                color: addNewCardButton.pressed ? "#5093E9" : (addNewCardButton.hovered? "#3E82DB" : "#2F72CA" )

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }

                            onClicked: {
                                addCardPopup.show()
                            }
                        }

                        /*------------DEBUG Button-----------*/
                        Button{
                            id: addCardDebug
                            Layout.preferredWidth:150
                            Layout.preferredHeight:45
                            padding:0
                            text: "Debug Add"
                            visible: false
                            
                            contentItem: Text {
                                text: addCardDebug.text
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
                                    console.log("Debug Add Clicked for User: " + cardsPage.userId)
                                    vaultBackend.addDebugCard(cardsPage.userId)
                             }
                        }


                    }

                    /*----------Headline-------------*/
                    ColumnLayout{
                        spacing: 10

                        RowLayout{
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
                        id: cardListView
                        Layout.preferredHeight: 470
                        Layout.fillWidth: true
                        clip: true
                        spacing: 10
                        model: cardsPage.filteredCardsList

                        delegate: Rectangle {
                            id: delegateRect
                            height: 70
                            width: cardListView.width // Use ListView width
                            radius: 10

                            property bool selected: false
                            property bool hovered: false

                            color: (selectedCard && selectedCard.id === modelData.id) ? "#111B2C" : 
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
                                    cardsPage.selectedCard = modelData
                                    console.log("Selected card: ", modelData.title)
                                     // Request card number decryption
                                    vaultBackend.decryptCard(cardsPage.userId, modelData.id)
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

                                        vaultBackend.setFavoriteCard(
                                            cardsPage.userId,
                                            modelData.id,
                                            newFavoriteStatus
                                        )

                                        var updatedList = []
                                        for (var i = 0; i < cardsList.length; i++) {
                                            if (cardsList[i].id === modelData.id) {
                                                // Create a new object with updated favorite status
                                                var updatedItem = Object.assign({}, cardsList[i])
                                                updatedItem.is_favorite = newFavoriteStatus
                                                updatedList.push(updatedItem)
                                            } else {
                                                updatedList.push(cardsList[i])
                                            }
                                        }
                                        
                                        // Reassign the entire array to trigger property binding
                                        cardsPage.cardsList = updatedList

                                        // Refresh filter in case we're in favorites mode
                                        filterCards()
                                    }       
                                }

                                Image{
                                    source: "../imgs/placeholders/card_default.png"
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 45
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
                                        text: modelData.cardholder_name
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
                            Layout.preferredHeight: 400
                            radius: 20

                            ColumnLayout{
                                anchors.rightMargin:20
                                anchors.leftMargin:20
                                anchors.topMargin:15
                                anchors.bottomMargin:15
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
                                        id: cardDetailImage
                                        Layout.preferredHeight: 60
                                        Layout.preferredWidth: 60
                                        source: "../imgs/placeholders/card_default.png"
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        }

                                        ColumnLayout{

                                            Label{
                                                id: detailCardNameLabel
                                                text: selectedCard ? selectedCard.title : " " 
                                                font.pixelSize: 20
                                            }

                                            Label{
                                                id: detailCardLastModLabel
                                                text: selectedCard ? selectedCard.last_modified : " "
                                                color: "#B5B5B5"
                                                font.pixelSize: 16
                                            }
                                        }
                                    }
                                
                                /*-------Details of Object*/
                               ColumnLayout{
                                spacing: 10

                                 /*----------Cardholder Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Cardholder"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth: true
                                        }

                                        Label{
                                            id: cardDetailsUsernameLabel
                                            text: selectedCard ? selectedCard.cardholder_name : " "
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

                                 /*----------Card Type Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Type"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Image{
                                            id: cardTypeImage
                                            Layout.preferredHeight: 20
                                            Layout.preferredWidth: 30
                                            fillMode: Image.PreserveAspectFit
                                            source: {
                                                console.log(selectedCard.card_type)
                                                if (!selectedCard) return "../imgs/placeholders/mastercard.svg"
                                                
                                                var cardType = selectedCard.card_type.trim()
                                                
                                                if (cardType === "Mastercard") {
                                                    return "../imgs/placeholders/mastercard.svg"
                                                } else if (cardType === "Visa") {
                                                    return "../imgs/placeholders/visa.png"
                                                } else {
                                                    return "../imgs/cards.png"
                                                }
                                            }
                                            visible: selectedCard !== null
                                        }

                                        Label{
                                            id:cardTypeLabel
                                            text: selectedCard ? selectedCard.card_type : " "
                                            color: "white"
                                            font.pixelSize:18
                                        }
                                    }

                                    Rectangle{
                                        color: "#7B7B7B"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 2
                                        opacity: 0.3
                                    }
                                
                                }

                                /*----------Card Number Row---------------*/
                                ColumnLayout{
                                    spacing: 5

                                    RowLayout{
                                        spacing: 0
                                        Layout.fillWidth:true

                                        Label{
                                            text: "Card Number"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Label{
                                            id: cardDetailsCreditNumberLabel
                                            text: selectedCard ?
                                            (cardNumberVisibilityOn ? decryptedCardNumber : "**** **** **** ****")
                                            : "**** **** **** ****"
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }

                                        Button{
                                            id: changeCreditNumberVisibilityButton
                                            background: Rectangle{
                                                color: "transparent"
                                            }

                                            contentItem: Image{
                                            height: 30
                                            width: 30 
                                            source: cardNumberVisibilityOn ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                        }
                                        onClicked:{
                                            if(!selectedCard) return
                                            cardNumberVisibilityOn = !cardNumberVisibilityOn
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



                                /*----------Card CVV Row---------------*/
                                ColumnLayout{
                                    spacing: 5

                                    RowLayout{
                                        spacing: 0
                                        Layout.fillWidth:true

                                        Label{
                                            text: "CVV"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Label{
                                            id: passDetailsPasswordLabel
                                            text: selectedCard ?
                                            (cvvVisibilityOn ? decryptedCvv : "***" )
                                            : "***"
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }

                                        Button{
                                            id: changeCvvVisibilityButton
                                            background: Rectangle{
                                                color: "transparent"
                                            }

                                            contentItem: Image{
                                            height: 30
                                            width: 30 
                                            source: cvvVisibilityOn ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
                                        }
                                        onClicked:{
                                            if(!selectedCard) return
                                            cvvVisibilityOn = !cvvVisibilityOn
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

                                /*----------Card Expiration Date Row---------------*/
                                ColumnLayout{
                                    spacing: 10

                                    RowLayout{
                                        spacing: 5

                                        Label{
                                            text: "Expiration Date:"
                                            color: "white"
                                            font.pixelSize: 15
                                        }

                                        Item{
                                            Layout.fillWidth:true
                                        }

                                        Label{
                                            id: cardDetailsExpirationDate
                                            text: selectedCard ? selectedCard.expiration_date : " "
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

                                /*----------------Note Display (Read-Only)---------------*/
                                TextField{
                                    id: passAddANote
                                    placeholderText: "No note"
                                    text: selectedCard ? selectedCard.note : ""
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
                                spacing: 20


                                /*--------------Created at Row------------*/
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
                                            text: selectedCard ? selectedCard.created_at : " "
                                            color: "#B5B5B5"
                                            font.pixelSize: 15
                                        }
                                }

                                /*--------------Last Modified Row------------*/
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
                                            text: selectedCard ? selectedCard.last_modified : " "
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

                                Behavior on color{
                                    ColorAnimation { duration: 150}
                                }
                            }

                            onClicked: {
                                if (!selectedCard) return
                                // Populate edit popup with selected card data
                                editCardPopup.cardId = selectedCard.id
                                editCardPopup.userId = cardsPage.userId
                                editCardPopup.masterPassword = cardsPage.masterPassword
                                editCardPopup.titleText = selectedCard.title || ""
                                editCardPopup.holderText = selectedCard.cardholder_name || ""
                                editCardPopup.numberText = decryptedCardNumber || "Loading..."
                                editCardPopup.cvvText = decryptedCvv || "..."
                                editCardPopup.expiryText = selectedCard.expiration_date || ""
                                editCardPopup.cardTypeText = selectedCard.card_type || ""
                                editCardPopup.noteText = selectedCard.note || ""
                                editCardPopup.populateFields()
                                editCardPopup.show()
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
                                if (!selectedCard) return
                                deleteCardConfirmation.open()
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