import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: watchTowerPage
    width: 1500
    height: 1080

    // --- PROPERTIES ---
    property string userId: ""
    property string masterPassword: ""
    property bool isChecking: false
    property real progressValue: 0.0

    property int weakCount: 0
    property int reusedCount: 0
    property int breachedCount: 0

    property bool hasBreaches: breachedCount > 0
    property bool isVaultStrong: !isChecking && weakCount === 0 && reusedCount === 0 && breachedCount === 0

    property var weakList: []
    property var reusedList: []
    property var breachedList: []

    // --- SIGNAL ---
    signal requestEditPassword(int passwordId) 

    // --- TIMER ---
    Timer {
        id: scanTimer
        interval: 500
        repeat: false
        running: false
        onTriggered: {
            if (userId !== "" && masterPassword !== "") {
                watchTowerPage.weakList = []
                watchTowerPage.reusedList = []
                watchTowerPage.breachedList = []
                watchTowerBackend.startScan(userId, masterPassword)
            }
        }
    }

    // --- CONNECTIONS ---
    Connections {
        target: watchTowerBackend

        function onIsScanningChanged(scanning) {
            watchTowerPage.isChecking = scanning
        }

        function onScanFinished(weak, reused, breached) {
            watchTowerPage.weakCount = weak
            watchTowerPage.reusedCount = reused
            watchTowerPage.breachedCount = breached
        }
        
        function onScanDataReady(weakItems, reusedItems, breachedItems) {
            watchTowerPage.weakList = weakItems
            watchTowerPage.reusedList = reusedItems
            watchTowerPage.breachedList = breachedItems
        }

        function onScanProgressUpdated(val) {
            watchTowerPage.progressValue = val
        }
    }

    // --- EKKINHSH ---
    Component.onCompleted: {
        if (userId !== "" && masterPassword !== "") {
             scanTimer.start()
        }
    }
    
    onUserIdChanged: {
        if (userId !== "" && masterPassword !== "") {
             scanTimer.restart()
        }
    }

    // --- UI DISPLAY ---
    Rectangle {
        color: "#1E2634"
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 40

            // ΚΥΡΙΑ ΣΤΗΛΗ
            ColumnLayout {
                Layout.margins: 30
                Layout.fillHeight: true
                Layout.fillWidth: true

                Label {
                    text: "Watchtower"
                    color: "white"
                    font.pointSize: 28
                    font.bold: true
                }

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 70
                    Layout.alignment: Qt.AlignTop 

                    // --- ΑΡΙΣΤΕΡΗ ΣΤΗΛΗ ---
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 20

                        Label {
                            text: isChecking ? "Scanning vault..." : "Scan complete"
                            color: isChecking ? "#7ADCB4" : "white"
                            font.pixelSize: 20
                        }

                        // Progress Bar
                        Rectangle {
                            id: nowCheckingItem
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 400
                            radius: 20
                            color: "#1E2634"
                            border.color: (isChecking || progressValue >= 1.0) ? "#7ADCB4" : "white"
                            border.width: 2
                            clip: true

                            Rectangle {
                                height: parent.height - 10
                                width: (parent.width - 20) * watchTowerPage.progressValue
                                radius: 15
                                color: watchTowerPage.progressValue >= 1.0 ? "#7ADCB4" : "#303946"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                Behavior on width { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 200 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "Scan Complete"
                                    color: "#1E2634"
                                    font.bold: true
                                    visible: watchTowerPage.progressValue >= 1.0
                                    opacity: visible ? 1.0 : 0.0
                                    Behavior on opacity { NumberAnimation { duration: 300 } }
                                }
                            }
                        }

                        Label { text: "Password policy check:"; color: "white"; font.pixelSize: 20 }

                        // Stats Box
                        Rectangle {
                            Layout.preferredHeight: 350
                            Layout.preferredWidth: 400
                            radius: 20
                            color: "#1E2634"
                            border.color: "white"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15

                                RowLayout {
                                    spacing: 15
                                    Image {
                                        source: weakCount === 0 ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                        Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Label { text: "No weak passwords"; color: "white"; font.pixelSize: 18 }
                                }

                                RowLayout {
                                    spacing: 15
                                    Image {
                                        source: reusedCount === 0 ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                        Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Label { text: "No reused passwords"; color: "white"; font.pixelSize: 18 }
                                }

                                Rectangle { Layout.fillWidth: true; height: 1; color: "gray"; opacity: 0.5 }

                                Label { text: "Stats found:"; color: "#B5B5B5"; font.pixelSize: 16 }
                                Label { text: "• " + weakCount + " weak passwords"; color: weakCount > 0 ? "#F76262" : "white"; font.pixelSize: 16 }
                                Label { text: "• " + reusedCount + " reused passwords"; color: reusedCount > 0 ? "#F76262" : "white"; font.pixelSize: 16 }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        Label { text: "Exposed in data breaches?"; color: "white"; font.pixelSize: 20 }

                        // Breach Box
                        Rectangle {
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 400
                            radius: 20
                            color: hasBreaches ? "#381E1E" : (isChecking ? "#1E2634" : "#1E382A")
                            border.color: hasBreaches ? "#F65151" : "#7ADCB4"
                            border.width: 2

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 10
                                Image {
                                    source: hasBreaches ? "../imgs/error.png" : "../imgs/verified.png"
                                    Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                    fillMode: Image.PreserveAspectFit
                                }
                                Label {
                                    text: hasBreaches ? "Warning: " + breachedCount + " breaches found!" : "All good. No breaches found."
                                    color: hasBreaches ? "#F65151" : "#7ADCB4"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // --- ΔΕΞΙΑ ΣΤΗΛΗ ---
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 20

                        Label {
                            text: isChecking ? "Analyzing vault security..." : (isVaultStrong ? "Overall strength: Strong" : "Overall strength: Needs attention")
                            color: isChecking ? "white" : (isVaultStrong ? "#7ADCB4" : "#F65151")
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 600
                            radius: 20
                            color: isChecking ? "#303946" : (isVaultStrong ? "#7ADCB4" : "#F65151")
                            border.color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: isChecking ? "..." : (isVaultStrong ? "Excellent" : "Weak")
                                color: isChecking ? "white" : "#1E2634"
                                font.bold: true
                                font.pixelSize: 18
                            }
                        }

                        Label { text: "Action required:"; color: "white"; font.pixelSize: 20 }

                        // ΚΟΥΤΙ ΛΙΣΤΩΝ
                        Rectangle {
                            Layout.preferredHeight: 350 
                            Layout.preferredWidth: 600
                            radius: 20
                            color: "#1E2634"
                            border.color: "white"
                            border.width: 1

                            ScrollView {
                                id: scrollView
                                anchors.fill: parent
                                anchors.margins: 20 
                                clip: true
                                contentWidth: availableWidth 

                                // ScrollBar
                                ScrollBar.vertical: ScrollBar {
                                    parent: scrollView
                                    x: scrollView.width - width - 5
                                    y: scrollView.topPadding
                                    height: scrollView.availableHeight
                                    active: true // Πάντα ενεργή
                                    policy: ScrollBar.AlwaysOn // Πάντα ορατή
                                    
                                    contentItem: Rectangle { implicitWidth: 8; implicitHeight: 100; radius: 4; color: "#7ADCB4"; opacity: 0.8 }
                                    background: Rectangle { implicitWidth: 8; color: "transparent" }
                                }

                                ColumnLayout {
                                    width: parent.width - 20 
                                    spacing: 25
                                    visible: !isChecking

                                    // --- 1. Breached List ---
                                    ColumnLayout {
                                        visible: breachedCount > 0
                                        spacing: 10
                                        Layout.fillWidth: true
                                        Label { text: "⚠️ Compromised (" + breachedCount + ")"; color: "#F65151"; font.bold: true; font.pixelSize: 16 }
                                        
                                        Repeater {
                                            model: watchTowerPage.breachedList
                                            delegate: Rectangle {
                                                height: breachedContent.implicitHeight + 30
                                                Layout.fillWidth: true
                                                radius: 10
                                                color: ma1.containsMouse ? "#502828" : "#381E1E"
                                                
                                                MouseArea {
                                                    id: ma1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: watchTowerPage.requestEditPassword(modelData.id)
                                                }

                                                ColumnLayout {
                                                    id: breachedContent
                                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15
                                                    spacing: 5
                                                    
                                                    // Header Row
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        Text { text: modelData.title; color: "white"; font.bold: true; font.pixelSize: 16; Layout.fillWidth: true; elide: Text.ElideRight }
                                                        Rectangle { color: "#F65151"; height: 24; width: 80; radius: 5; Text { anchors.centerIn: parent; text: "BREACHED"; color: "white"; font.bold: true; font.pixelSize: 11 } }
                                                    }
                                                    Text { text: modelData.username; color: "#B5B5B5"; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    // Info Row
                                                    Text { text: modelData.description; color: "#F65151"; font.pixelSize: 12; font.italic: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                                }
                                            }
                                        }
                                    }

                                    // --- 2. Weak List ---
                                    ColumnLayout {
                                        visible: weakCount > 0
                                        spacing: 10
                                        Layout.fillWidth: true
                                        Label { text: "⚠️ Weak Passwords (" + weakCount + ")"; color: "#F29A7A"; font.bold: true; font.pixelSize: 16 }
                                        
                                        Repeater {
                                            model: watchTowerPage.weakList
                                            delegate: Rectangle {
                                                height: weakContent.implicitHeight + 30
                                                Layout.fillWidth: true
                                                radius: 10
                                                color: ma2.containsMouse ? "#553B32" : "#3E2C26"
                                                
                                                MouseArea {
                                                    id: ma2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: watchTowerPage.requestEditPassword(modelData.id)
                                                }

                                                ColumnLayout {
                                                    id: weakContent
                                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15
                                                    spacing: 5

                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        Text { text: modelData.title; color: "white"; font.bold: true; font.pixelSize: 16; Layout.fillWidth: true; elide: Text.ElideRight }
                                                        Rectangle { color: "#F29A7A"; height: 20; width: 60; radius: 5; Text { anchors.centerIn: parent; text: "WEAK"; color: "#3E2C26"; font.bold: true; font.pixelSize: 10 } }
                                                    }
                                                    Text { text: modelData.username; color: "#B5B5B5"; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                                }
                                            }
                                        }
                                    }

                                    // --- 3. Reused List ---
                                    ColumnLayout {
                                        visible: reusedCount > 0
                                        spacing: 10
                                        Layout.fillWidth: true
                                        Label { text: "⚠️ Reused Passwords (" + reusedCount + ")"; color: "#F2CA7A"; font.bold: true; font.pixelSize: 16 }
                                        
                                        Repeater {
                                            model: watchTowerPage.reusedList
                                            delegate: Rectangle {
                                                height: reusedContent.implicitHeight + 30
                                                Layout.fillWidth: true
                                                radius: 10
                                                color: ma3.containsMouse ? "#554A32" : "#3E3626"

                                                MouseArea {
                                                    id: ma3; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    onClicked: watchTowerPage.requestEditPassword(modelData.id)
                                                }

                                                ColumnLayout {
                                                    id: reusedContent
                                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 15
                                                    spacing: 5

                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        Text { text: modelData.title; color: "white"; font.bold: true; font.pixelSize: 16; Layout.fillWidth: true; elide: Text.ElideRight }
                                                        Rectangle { color: "#F2CA7A"; height: 20; width: 60; radius: 5; Text { anchors.centerIn: parent; text: "REUSED"; color: "#3E3626"; font.bold: true; font.pixelSize: 10 } }
                                                    }
                                                    Text { text: modelData.username; color: "#B5B5B5"; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    Text { text: modelData.description; color: "#B5B5B5"; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true; Layout.topMargin: 5 }
                                                }
                                            }
                                        }
                                    }

                                    // Success Message
                                    Item { 
                                        visible: isVaultStrong && !isChecking
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 10
                                            Image {
                                                source: "../imgs/verified.png" 
                                                Layout.preferredWidth: 40; Layout.preferredHeight: 40
                                                Layout.alignment: Qt.AlignHCenter
                                                visible: true; fillMode: Image.PreserveAspectFit
                                            }
                                            Text {
                                                text: "Great job! Your vault is secure."
                                                color: "#7ADCB4"; font.pixelSize: 18; font.bold: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
            
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "#161C26"; radius: 25
            }
        }
    }
}