import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    id: generatorPage
    width: 1500
    height: 1080

    // Connection to receive generated password from backend
    Connections {
        target: generatorBackend
        function onPassword_generated(password, strength) {
            generatedRandomPassword.text = password
            console.log("Generated password with strength: " + strength)
        }
    }

    // Generate password on page load
    Component.onCompleted: {
        generatorBackend.generateDefaultPassword()
    }

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
                    text: "Click generate to create password"
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

                        onClicked: {
                            var len = parseInt(lengthTextField.text) || 16
                            generatorBackend.generatePassword(
                                len,
                                upperCaseCheck.checked,
                                lowerCaseCheck.checked,
                                digitsCheck.checked,
                                specialCheck.checked,
                                avoidAmbiguousCheck.checked
                            )
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

                        onClicked: {
                            // Copy to clipboard
                            textHelper.text = generatedRandomPassword.text
                            textHelper.selectAll()
                            textHelper.copy()
                            console.log("Password copied to clipboard")
                        }

                    }

                    // Hidden helper for clipboard access
                    TextEdit {
                        id: textHelper
                        visible: false
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
                            id: upperCaseCheck
                            text: "A-Z"
                            checked: true
                            font.pixelSize: 16
                            contentItem: Text {
                                text: upperCaseCheck.text
                                font: upperCaseCheck.font
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: upperCaseCheck.indicator.width + upperCaseCheck.spacing
                            }
                        }

                        CheckBox{
                            id: lowerCaseCheck
                            text: "a-z"
                            checked: true
                            font.pixelSize: 16
                            contentItem: Text {
                                text: lowerCaseCheck.text
                                font: lowerCaseCheck.font
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: lowerCaseCheck.indicator.width + lowerCaseCheck.spacing
                            }
                        }

                        CheckBox{
                            id: digitsCheck
                            text: "0-9"
                            checked: true
                            font.pixelSize: 16
                            contentItem: Text {
                                text: digitsCheck.text
                                font: digitsCheck.font
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: digitsCheck.indicator.width + digitsCheck.spacing
                            }
                        }

                        CheckBox{
                            id: specialCheck
                            text: "!@#$%^&*"
                            checked: true
                            font.pixelSize: 16
                            contentItem: Text {
                                text: specialCheck.text
                                font: specialCheck.font
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: specialCheck.indicator.width + specialCheck.spacing
                            }
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
                            id: avoidAmbiguousCheck
                            text: "Avoid ambiguous characters"
                            checked: false
                            font.pixelSize: 16
                            contentItem: Text {
                                text: avoidAmbiguousCheck.text
                                font: avoidAmbiguousCheck.font
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: avoidAmbiguousCheck.indicator.width + avoidAmbiguousCheck.spacing
                            }
                        }
                }

            }



            Item{
                Layout.fillHeight: true
            }
        }
    }

}