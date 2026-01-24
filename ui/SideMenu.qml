import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: root
    width:1500
    height:1080

    signal logoutClicked()
    property string currentPage: "passwords"
    property string userIdString: ""
    property string masterPassword: ""

    Connections {
        target: vaultBackend
        function onVaultDeleted(success, message){
            if(success){
                console.log("SideMenu: Vault deleted. Logging out.")
                root.logoutClicked()
            }
        }
    }

    function updatePage() {
        var page;
        var props = {};
        switch(currentPage){
            case "passwords": 
                page = "PasswordsPage.qml"; 
                props = {"userId": root.userIdString, "masterPassword": root.masterPassword};
                break;
            case "cards":
                page = "CardsPage.qml";
                props = {"userId": root.userIdString, "masterPassword": root.masterPassword};
                break;
            case "watchTower": // ΝΕΟ
                page = "WatchTowerPage.qml"; 
                props = {"userId": root.userIdString,"masterPassword": root.masterPassword}; 
                break;
            case "generator": page = "GeneratorPage.qml"; break;
            case "settings": 
                page = "SettingsPage.qml"; 
                props = {"userId": root.userIdString};
                break;
        }
        if(page) stack.replace(page, props);
    }

   Rectangle{
    color: "#1E2634"
    anchors.fill:parent

     RowLayout{
        anchors.fill: parent
        spacing: 0
        

        /* ------Side Menu ------------*/
        Rectangle{
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#303946"
            radius: 10

            ColumnLayout{
                anchors.fill:parent
                anchors.margins:10
                spacing: 15

                /*--------Image and Titles------------*/
                RowLayout{
                    Layout.fillWidth: true
                    spacing: 15

                    Image {
                        id: gkip_logo
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 70
                        source: "../imgs/gkip_logo.png"
                        Layout.topMargin: 30
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout{
                        spacing: 5

                        Label {
                            text: "GKIP"
                            color: "white"
                            font.pointSize: 24
                            font.bold: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Label {
                            text: "   Password Manager"
                            color: "white"
                            font.pointSize: 12
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Item{
                    Layout.preferredHeight: 20
                }

                /*----------Menu Buttons--------------*/

                //Passwords Button
                Button{
                    id: passwordsMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/verified.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "Passwords"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: currentPage === "passwords" ? "#1A222B" : (passwordsMenuButton.pressed ? "#353F4A" :  (passwordsMenuButton.hovered ? "#252D36" : "#303946" ))
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        currentPage = "passwords";
                        updatePage();
                    }
                }

                //Cards Button
                Button{
                    id: cardsMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/cards.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "Cards"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: currentPage === "cards" ? "#1A222B" : (cardsMenuButton.pressed ? "#353F4A" :  (cardsMenuButton.hovered ? "#252D36" : "#303946" ))
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        currentPage = "cards";
                        updatePage();
                    }
                }

                //WatchTower Button
                Button{
                    id: watchTowerMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/watchTower.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "WatchTower"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: currentPage === "watchTower" ? "#1A222B" : (watchTowerMenuButton.pressed ? "#353F4A" :  (watchTowerMenuButton.hovered ? "#252D36" : "#303946" ))
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        currentPage = "watchTower";
                        updatePage();
                    }
                }

                //Generator Button
                Button{
                    id: generatorMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/generate.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "Generator"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: currentPage === "generator" ? "#1A222B" : (generatorMenuButton.pressed ? "#353F4A" :  (generatorMenuButton.hovered ? "#252D36" : "#303946" ))
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        currentPage = "generator";
                        updatePage();
                    }
                }

                //Settings Button
                Button{
                    id: settingsMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/settings.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "Settings"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: currentPage === "settings" ? "#1A222B" : (settingsMenuButton.pressed ? "#353F4A" :  (settingsMenuButton.hovered ? "#252D36" : "#303946" ))
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        currentPage = "settings";
                        updatePage();
                    }
                }

                Item{
                    Layout.preferredHeight: 170
                }

                /*--------White Line---------*/
                Rectangle{
                    color: "white"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    opacity: 0.3
                }
                
                //Logout Button
                Button{
                    id: logoutMenuButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    padding: 0

                    contentItem: Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Row{
                            anchors.centerIn: parent
                            spacing: 5

                            Image{
                                height: 25
                                width: 25
                                source: "../imgs/logout.png"
                                fillMode: Image.PreserveAspectFit
                            }

                            Text{
                                text: "Log Out"
                                color: "white"
                                font.pixelSize: 20
                            }
                        }
                    }
                    
                    background: Rectangle{ 
                        color: logoutMenuButton.pressed ? "#353F4A" :  (logoutMenuButton.hovered ? "#252D36" : "#303946" )
                        radius: 8

                        Behavior on color {
                            ColorAnimation { duration:150}
                        }
                    }
                    onClicked:{
                        root.logoutClicked()
                    }
                }

                Item{
                    Layout.fillHeight: true
                }
            }
        }
    
        /* ----------Show Pages ----------*/
        Component {
            id: firstPasswordPage
            PasswordsPage {
                userId: root.userIdString
                masterPassword: root.masterPassword
            }
        }

        StackView{
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: firstPasswordPage

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
