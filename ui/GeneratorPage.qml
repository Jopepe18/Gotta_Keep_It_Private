import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: generatorPage
    width: 1500
    height: 1080

    Rectangle{
        color: "#1E2634"
        anchors.fill: parent

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            Label{
                text: "Generator"
                color: "white"
                font.pointSize:  28
            }

            Label{
                text: "Generate"
                color: "white"
                font.pointSize: 20
            }

            Rectangle{
                        Layout.preferredHeight: 60
                        Layout.preferredWidth: 700
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

                    Label{
                    id: generatedRandomPassword
                    text: "39jrfe22012DEje23"
                    color: "white"
                    font.pointSize: 16
                    }

                    Item{
                        Layout.fillWidth: true
                    }

                    Button{
                        id: generatePasswordButton
                        background: Rectangle{
                            radius: 20
                            color: generatePasswordButton.pressed? "#3A404B" : (generatePasswordButton.hovered?   "#2E3646": "#1E2634")
                        }
                        Layout.preferredWidth:50
                        Layout.preferredHeight: 50

                        contentItem: Image{
                            height: 24
                            width: 24
                            source: "../imgs/generate.png"
                            fillMode: Image.PreserveAspectFit
                        }

                    }

                    Button{
                        id: copyGeneratedPassButton
                        background: Rectangle{
                            radius: 20
                            color: copyGeneratedPassButton.pressed? "#3A404B" : (copyGeneratedPassButton.hovered?   "#2E3646": "#1E2634")
                        }
                        Layout.preferredWidth:50
                        Layout.preferredHeight: 50

                        contentItem: Image{
                            height: 24
                            width: 24
                            source: "../imgs/copy_text.png"
                            fillMode: Image.PreserveAspectFit
                        }

                    }


                }
            }

            Label{
                text: "Options"
                color: "white"
                font.pointSize: 20
            }

            Rectangle{
                        Layout.preferredHeight: 175
                        Layout.preferredWidth: 700
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"

                ColumnLayout{
                    anchors.fill: parent
                    anchors.topMargin:20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    Label{
                        text: "Length"
                        color: "white"
                        font.pointSize: 18
                    }


                    Rectangle{
                        Layout.preferredHeight: 50
                        Layout.preferredWidth: 640
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
                                text: "10"
                                font.pixelSize: 16
                                id: lengthTextField

                                background: Rectangle{
                                    color: "transparent"
                                }
                            }
                        }
                    }

                    Label{
                        text: "Value must be between 5 and 20. Use 14 characters or more to generate a strong password."
                        font.pixelSize: 14
                        color: "#A2A2A2"
                        }

                    Item{
                        Layout.fillHeight: true
                    }

                }
            }

            Rectangle{
                        Layout.preferredHeight: 270
                        Layout.preferredWidth: 700
                        radius: 20
                        color: "#1E2634"
                        border.color: "white"

                ColumnLayout{
                    anchors.fill: parent
                    anchors.topMargin:20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 15

                    RowLayout{
                        spacing: 20

                        CheckBox{
                            text: "A-Z"
                            checked: false
                            font.pixelSize: 16
                        }

                        CheckBox{
                            text: "a-z"
                            checked: false
                            font.pixelSize: 16                            
                        }

                        CheckBox{
                            text: "0-9"
                            checked: false
                            font.pixelSize: 16 
                        }

                        CheckBox{
                            text: "!@#$%^&*"
                            checked: false
                            font.pixelSize: 16 
                        }


                    }
                
                 RowLayout{
                    spacing: 25

                    ColumnLayout{
                        spacing:15

                        Label{
                            text: "Minimum Numbers"
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
                                text: "10"
                                font.pixelSize: 16
                                id: minNumbersTextField

                                background: Rectangle{
                                    color: "transparent"
                                }
                            }
                        }
                    }
                    }

                    ColumnLayout{
                        spacing:15

                        Label{
                            text: "Maximum Numbers"
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
                                text: "10"
                                font.pixelSize: 16
                                id: maxNumbersTextField

                                background: Rectangle{
                                    color: "transparent"
                                    }
                                }
                            }
                        }
                     }
                
                
                }
                
                 CheckBox{
                            text: "Avoid ambiguous characters"
                            checked: false
                            font.pixelSize: 16
                        }
                }

            }



            Item{
                Layout.fillHeight: true
            }
        }
    }

}