import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: passwordsPage
    width: 1300
    height: 1080

    property bool showFavorites: false
    property bool visibilityOn: false

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
                                    id: searchIcon
                                    Layout.preferredWidth: 20 
                                    Layout.preferredHeight: 20
                                    source: "../imgs/search.png"
                                    fillMode: Image.PreserveAspectFit
                                }

                                TextField{
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    placeholderText: "Search"
                                    color: "white"
                                    font.pixelSize: 16

                                    background: Rectangle{
                                        color: "transparent"
                                    }
                                }
                            }
                        }

                        /*------------Show Favorites Button-----------*/
                        Button{
                            id: showFavoritesButton
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
                                color: showFavoritesButton.pressed ? "#20B990" : (showFavoritesButton.hovered? "#109C77" : "#09946D" )

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

                    ScrollView{
                        id: passwordItemsScrollView
                        Layout.fillHeight:true
                        Column{

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
                        Layout.fillWidth:true
                        Layout.fillHeight:true

                       ColumnLayout{
                        Layout.margins: 20

                        Label{
                        text:"Details"
                        color: "white"
                        font.pointSize: 20
                        }

                        Rectangle{
                            color: "#303946"
                            Layout.preferredWidth:360
                            Layout.preferredHeight:400
                            radius: 20

                            ColumnLayout{
                                anchors.margins: 20

                                /*------------Image Title and Last Modification Labels*/
                                RowLayout{
                                    spacing: 20
                                    Layout.margins:20

                                        Image{
                                        id: detailImage
                                        Layout.preferredHeight: 60
                                        Layout.preferredWidth: 60
                                        source: "../imgs/placeholders/google.png"
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        }

                                        ColumnLayout{

                                            Label{
                                                id: detailPassNameLabel
                                                text: "Gmail"
                                                font.pixelSize: 20
                                            }

                                            Label{
                                                id: detailPassLastModLabel
                                                text: "Last modified: 12/7/2025"
                                                color: "#B5B5B5"
                                                font.pixelSize: 16
                                            }
                                        }
                                    }
                                
                                /*----------Username Row---------------*/
                                ColumnLayout{
                                    Layout.margins: 20
                                    spacing: 10
                                    Layout.fillHeight: true

                                    RowLayout{
                                        spacing: 170

                                        Label{
                                            text: "Username"
                                            color: "white"
                                            font.pixelSize: 18
                                        }

                                        Label{
                                            id: passDetailsUsernameLabel
                                            text: "User"
                                            color: "#B5B5B5"
                                            font.pixelSize: 18
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
                                    Layout.margins: 20
                                    spacing: 10
                                    Layout.fillHeight: true

                                    RowLayout{
                                        spacing: 170

                                        Label{
                                            text: "Username"
                                            color: "white"
                                            font.pixelSize: 18
                                        }

                                        Label{
                                            id: passDetailsPasswordLabel
                                            text: "User"
                                            color: "#B5B5B5"
                                            font.pixelSize: 18
                                        }

                                        Button{
                                            id: changePasswordVisibilityButton
                                            contentItem: Image{
                                            height: 30
                                            width: 30 
                                            src: visibilityOn ? "../imgs/visibility_on.png" : "../imgs/visibility_off.png"
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
                                }
                                
                            }
                        }
                       }
                    }
                }

            }
        }

        
    
}