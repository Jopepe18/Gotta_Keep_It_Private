import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: watchTowerPage
    width: 1500
    height: 1080

    property bool isChecking: false
    property bool charactersChecked : true
    property bool capitalChecked: false
    property bool numberChecked: false
    property bool specialChecked: true
    property bool noSpacesChecked: false
    property bool itemExposedInBreach: false
    

        Rectangle{
            color: "#1E2634"
            anchors.fill: parent

         RowLayout{
            anchors.fill: parent

            spacing: 40

            ColumnLayout{
                Layout.margins: 30

            Label{
                text: "Watch Tower"
                color: "white"
                font.pointSize: 28
            }

            RowLayout{
                Layout.fillHeight: true
                Layout.fillWidth:  true
                spacing: 70

                ColumnLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    Label{
                        text: isChecking ? "Now Checking..." : ""
                        color: "white"
                        font.pixelSize: 20
                    }

                    Rectangle{
                        id: nowCheckingItem
                        Layout.preferredHeight: 60
                        Layout.preferredWidth: 400
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"
                    }

                    Item{
                        Layout.preferredHeight: 20
                    }
                    
                    Label{
                        text: "Passwords must include: " 
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

                            /*---------Characters Checking Row---------------------*/
                            RowLayout{
                                Layout.fillWidth: true
                                
                                Image{
                                    id: passCheckCharImage
                                    height: 30
                                    width: 30
                                    fillMode: Image.PreserveAspectFit
                                    source: charactersChecked ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                }

                                Label{
                                    text: "8-20 Characters" 
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }

                            /*---------Characters Checking Row---------------*/
                            RowLayout{
                                Layout.fillWidth: true
                                
                                Image{
                                    id: passCheckCapImage
                                    height: 30
                                    width: 30
                                    fillMode: Image.PreserveAspectFit
                                    source: capitalChecked ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                }

                                Label{
                                    text: "At least 1 capital letter" 
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }

                            /*---------Numbers Checking Row-------------*/
                            RowLayout{
                                Layout.fillWidth: true
                                
                                Image{
                                    id: passCheckNumImage
                                    height: 30
                                    width: 30
                                    fillMode: Image.PreserveAspectFit
                                    source: numberChecked ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                }

                                Label{
                                    text: "At least one number" 
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }

                            /*---------Special Characters Checking Row------------*/
                            RowLayout{
                                Layout.fillWidth: true
                                
                                Image{
                                    id: passCheckSpecImage
                                    height: 30
                                    width: 30
                                    fillMode: Image.PreserveAspectFit
                                    source: specialChecked ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                }

                                Label{
                                    text: "At least one special Characters" 
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }

                            /*---------No Spaces Checking Row---------*/
                            RowLayout{
                                Layout.fillWidth: true
                                
                                Image{
                                    id: passCheckSpacesImage
                                    height: 30
                                    width: 30
                                    fillMode: Image.PreserveAspectFit
                                    source: noSpacesChecked ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                }

                                Label{
                                    text: "No spaces" 
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }



                        }


                    }

                    Item{
                        Layout.preferredHeight: 20
                    }

                    Label{
                        text: "Exposed in data Breaches? " 
                        color: "white"
                        font.pixelSize: 20
                    }

                     Rectangle{
                        id: exposedItemInBreach
                        Layout.preferredHeight: 60
                        Layout.preferredWidth: 400
                        radius: 20
                        color: isChecking ? (itemExposedInBreach? "#F65151": "#7ADCB4") :"#1E2634"
                        border.color:  isChecking ? (itemExposedInBreach? "#D81010": "#00D082") : "white"
                    }

                }

                ColumnLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop


                    Label{
                        text: isChecking? "Strong" : "Password Strength "
                        color: "white"
                        font.pixelSize: 20
                    }

                    Rectangle{
                        Layout.preferredHeight: 45
                        Layout.preferredWidth: 300
                        radius: 20
                        color: isChecking? ("#7ADCB4") : "#1E2634"
                        border.color: "white"
                    }

                     Item{
                        Layout.preferredHeight: 30
                    }

                    Label{
                        text: "Checked Passwords: " 
                        color: "white"
                        font.pixelSize: 20
                    }

                     Rectangle{
                        Layout.preferredHeight: 350
                        Layout.preferredWidth: 400
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"
                    

                        ScrollView{
                            ColumnLayout{
                                id: checkedPasswordsScroll
                            Layout.margins: 15
                        }
                        }
                     }
                }

            }

            Item{
                Layout.fillHeight: true
            }

            }

            Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#161C26"
                    radius: 25
                }
            
                    
         }

    }

}