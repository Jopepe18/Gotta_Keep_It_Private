import QtQuick
import QtQuick.Controls
import PasswordManager

Rectangle {
    id: rectangle
    width: 1500
    height: Constants.height

    color: Constants.backgroundColor

    Column {
        id: menu_bar
        x: 0
        y: 0
        width: 400
        height: 874
        bottomPadding: 20
        topPadding: 40
        spacing: 50
        scale: 1
        transformOrigin: Item.Left

        BorderImage {
            id: borderImage
            x: 25
            width: 350
            height: 200
            source: "qrcimages/template_image.png"
            transformOrigin: Item.Center
        }

        TabButton {
            id: password_tab
            width: menu_bar.width
            height: 50
            text: qsTr("Passwords")
        }

        TabButton {
            id: crecitcard_tab
            width: menu_bar.width
            height: 50
            text: qsTr("Credit Cards")
        }

        TabButton {
            id: watchtower_tab
            width: menu_bar.width
            height: 50
            text: qsTr("WatchTower")
        }

        TabButton {
            id: generator_tab
            width: menu_bar.width
            height: 50
            text: qsTr("Generator")
        }
    }

    Frame {
        id: frame_grid
        x: 406
        y: 138
        width: 1094
        height: 942

        GridView {
            id: gridView
            x: 36
            y: 9
            width: 1005
            height: 900
            model: ListModel {
                ListElement {
                    name: "Grey"
                    colorCode: "grey"
                }

                ListElement {
                    name: "Red"
                    colorCode: "red"
                }

                ListElement {
                    name: "Blue"
                    colorCode: "blue"
                }

                ListElement {
                    name: "Green"
                    colorCode: "green"
                }
            }
            delegate: Item {
                x: 5
                height: 50
                Column {
                    spacing: 5
                    Rectangle {
                        width: 40
                        height: 40
                        color: colorCode
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        x: 5
                        text: name
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            cellWidth: 70
            cellHeight: 70
        }
    }

    Row {
        id: row_topright
        x: 398
        y: 0
        width: 1102
        height: 132
        leftPadding: 50
        topPadding: 40
        spacing: 90

        TextField {
            id: search_textfield
            width: 450
            placeholderText: qsTr("Search")
        }

        Button {
            id: favorites_button
            width: 90
            height: 65
            text: qsTr("Favorites")
            icon.source: "../../imgs/favoritesfolder_icon.png"
            display: AbstractButton.IconOnly
        }
    }

    TabButton {
        id: settings_button
        x: 0
        y: 998
        width: menu_bar.width
        height: 50
        text: qsTr("Settings")
        topInset: 0
        topPadding: 0
    }
    states: [
        State {
            name: "clicked"
        }
    ]
}
