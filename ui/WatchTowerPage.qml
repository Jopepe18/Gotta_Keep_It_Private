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
    property int totalItems: 0
    property string vaultScore: "..."
    property bool hasBreaches: breachedCount > 0
    property bool hasNetworkError: false

    // json lists for the action requiered 
    property var weakList: []
    property var reusedList: []
    property var breachedList: []

    // properties for the graphs
    property int chartWeak: 0
    property int chartReused: 0
    property int chartBreached: 0
    property int chartSafe: 0
    
    
    function getScoreColor() {
        if (isChecking) return "#303946"
        
        switch (vaultScore) {
            case "Critical": return "#F65151"       // Κόκκινο
            case "Weak": return "#F65151"           // Κόκκινο
            case "Needs Attention": return "#F29A7A" // Πορτοκαλί
            case "Good": return "#F2CA7A"           // Κίτρινο
            case "Strong": return "#7ADCB4"         // Ανοιχτό Πράσινο
            case "Excellent": return "#7ADCB4"      // Πράσινο
            default: return "#303946"               // Default
        }
    }
   
    function getVaultHealth() {
        // Analyzing
        if (isChecking) return { text: "Analyzing...", color: "#303946", icon: "" }
        
        if (breachedCount > 0) {
            return { 
                text: "Critical Action Required", 
                color: "#F65151", 
                icon: "../imgs/broken_shield.png" // 
            } 
        }

        var totalIssues = weakCount + reusedCount
        if (totalIssues === 0) {
            return { 
                text: "Excellent", 
                color: "#7ADCB4", 
                icon: "../imgs/verified.png" 
            }
        }

        var ratio = totalIssues / (totalItems > 0 ? totalItems : 1)
        if (ratio < 0.25) {
            return { 
                text: "Good", 
                color: "#F2CA7A", 
                icon: "../imgs/warning.png" 
            } 
        }

        return { 
            text: "Needs Attention", 
            color: "#F29A7A", 
            icon: "../imgs/warning.png" 
        } 
    }

    // --- SIGNAL ---
    signal requestEditPassword(int passwordId)

    // --- ANALYTICS WINDOW ---
    AnalyticsWindow {
        id: analyticsWindow
    }

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

        function onScanFinished(weak, reused, breached, total, score,netError) {
            watchTowerPage.weakCount = weak
            watchTowerPage.reusedCount = reused
            watchTowerPage.breachedCount = breached
            watchTowerPage.totalItems = total
            watchTowerPage.vaultScore = score
            watchTowerPage.hasNetworkError = netError
        }

        function onScanDataReady(weakItems, reusedItems, breachedItems) {
            watchTowerPage.weakList = weakItems
            watchTowerPage.reusedList = reusedItems
            watchTowerPage.breachedList = breachedItems
        }
        function onChartStatsReady(weak, reused, breached, safe) {
            watchTowerPage.chartWeak = weak
            watchTowerPage.chartReused = reused
            watchTowerPage.chartBreached = breached
            watchTowerPage.chartSafe = safe
        }
        function onScanProgressUpdated(val) {
            watchTowerPage.progressValue = val
        }
    }

    // --- STARTUP ---
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

            // ΚΥΡΙΑ ΣΤΗΛΗ (Περιέχει τον τίτλο και τις δύο υπο-στήλες)
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

                        // Stats Box (Αριστερά)
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

                        // Breach Box (Κάτω Αριστερά)
                        Rectangle {
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 400
                            radius: 20
                            color: hasBreaches ? "#381E1E" : (hasNetworkError ? "#303946" : "#1E382A")
                            border.color: hasBreaches ? "#F65151" : (hasNetworkError ? "gray" : "#7ADCB4")
                            border.width: 2

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 10
                                Image {
                                    // Εικονίδιο: Error, Warning (για δίκτυο), ή Verified
                                    source: hasBreaches ? "../imgs/error.png" : (hasNetworkError ? "../imgs/warning.png" : "../imgs/verified.png")
                                    Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                    fillMode: Image.PreserveAspectFit
                                }
                                Label {
                                    // ΚΕΙΜΕΝΟ:
                                    text: hasBreaches ? "Warning: " + breachedCount + " breaches found!" : 
                                          (hasNetworkError ? "Breach check failed (Offline)" : "All good. No breaches found.")
                                    
                                    color: hasBreaches ? "#F65151" : (hasNetworkError ? "gray" : "#7ADCB4")
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                        }
                        
                        // Σπρώχνει τα πάντα προς τα πάνω στην αριστερή στήλη
                        Item { Layout.fillHeight: true }
                    }

                    // --- ΔΕΞΙΑ ΣΤΗΛΗ ---
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 20

                        Label {
                            text: isChecking ? "Analyzing vault security..." : "Overall Vault Strength"
                            color: "white"
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 600
                            radius: 20
                            color: getScoreColor()
                            border.color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: isChecking ? "..." : watchTowerPage.vaultScore
                                color: "#1E2634"
                                font.bold: true
                                font.pixelSize: 18
                            }
                        }

                        Label { text: "Action required:"; color: "white"; font.pixelSize: 20 }

                        // ΚΟΥΤΙ ΛΙΣΤΩΝ (Scrollable)
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

                                ScrollBar.vertical: ScrollBar {
                                    parent: scrollView
                                    x: scrollView.width - width - 5
                                    y: scrollView.topPadding
                                    height: scrollView.availableHeight
                                    active: true
                                    policy: ScrollBar.AlwaysOn
                                    contentItem: Rectangle { implicitWidth: 8; implicitHeight: 100; radius: 4; color: "#7ADCB4"; opacity: 0.8 }
                                    background: Rectangle { implicitWidth: 8; color: "transparent" }
                                }

                                ColumnLayout {
                                    width: parent.width - 20
                                    spacing: 25
                                    visible: !isChecking

                                    // Breached List
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
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        Text { text: modelData.title; color: "white"; font.bold: true; font.pixelSize: 16; Layout.fillWidth: true; elide: Text.ElideRight }
                                                        Rectangle { color: "#F65151"; height: 24; width: 80; radius: 5; Text { anchors.centerIn: parent; text: "BREACHED"; color: "white"; font.bold: true; font.pixelSize: 11 } }
                                                    }
                                                    Text { text: modelData.username; color: "#B5B5B5"; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                                    Text { text: modelData.description; color: "#F65151"; font.pixelSize: 12; font.italic: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                                }
                                            }
                                        }
                                    }

                                    //  Weak List
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

                                    // Reused List
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

                                    // Success Message (αν όλα είναι οκ)
                                    Item {
                                        // Εμφανίζεται ΜΟΝΟ αν ΔΕΝ ψάχνει ΚΑΙ όλα τα count είναι 0 ΚΑΙ υπάρχει τουλάχιστον 1 αντικείμενο.
                                        visible: !isChecking && weakCount === 0 && reusedCount === 0 && breachedCount === 0 && totalItems > 0
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
                        Item { Layout.preferredHeight: 20 }

                        // ANALYTICS BUTTON
                        Button {
                            id: analyticsButton
                            text: isChecking ? "Scanning..." : "View Security Analytics 📊"
                            Layout.preferredWidth: 600
                            Layout.preferredHeight: 60
                            enabled: !isChecking
                            opacity: enabled ? 1.0 : 0.5
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#252D36" : "#303946") : "#1E2634"
                                radius: 20
                                border.color: parent.enabled ? "#7ADCB4" : "gray"
                                border.width: 2
                            }

                            contentItem: Text {
                                text: analyticsButton.text
                                color: parent.enabled ? "#7ADCB4" : "gray" 
                                font.bold: true
                                font.pixelSize: 18
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            // άνοιγμα παραθύρου AnalyticsWindow
                            onClicked: {
                                analyticsWindow.weakCount = watchTowerPage.weakCount
                                analyticsWindow.reusedCount = watchTowerPage.reusedCount
                                analyticsWindow.breachedCount = watchTowerPage.breachedCount
                                analyticsWindow.totalItems = watchTowerPage.totalItems       
                                analyticsWindow.graphWeak = watchTowerPage.chartWeak
                                analyticsWindow.graphReused = watchTowerPage.chartReused
                                analyticsWindow.graphBreached = watchTowerPage.chartBreached
                                analyticsWindow.graphSafe = watchTowerPage.chartSafe
                                analyticsWindow.show()
                            }
                        }  
                        Item { Layout.fillHeight: true }
                    } 
                } 
            } 
        } 
    } 
} 