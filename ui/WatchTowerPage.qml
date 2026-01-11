import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: watchTowerPage
    width: 1500
    height: 1080

    // ΝΕΑ 
    property string userId: ""          
    property bool isChecking: false

    // ΝΕΑ 
    property int weakCount: 0            
    property int reusedCount: 0          
    property int breachedCount: 0    

    // ΝΕΑ 
    property bool hasBreaches: breachedCount > 0  
    property bool isVaultStrong: weakCount === 0 && reusedCount === 0 && breachedCount === 0 && !isChecking

    Connections {  // ΝΕΟ: Aκούει το WatchTowerBackend 
        target: watchTowerBackend

        function onIsScanningChanged(scanning) {
            watchTowerPage.isChecking = scanning
        }

        function onScanFinished(weak, reused, breached) {
            watchTowerPage.weakCount = weak
            watchTowerPage.reusedCount = reused
            watchTowerPage.breachedCount = breached
            console.log("WatchTower Updated: Weak=" + weak + ", Reused=" + reused + ", Breached=" + breached)
        }
    }

    // NEO: Ξεκινάει το scan μόλις ανοίξει η σελίδα
    onUserIdChanged: {  
        if (userId !== "") watchTowerBackend.startScan(userId)
    }
    
    Component.onCompleted: {  
        if (userId !== "") watchTowerBackend.startScan(userId)
    }

    Rectangle {
        color: "#1E2634"
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 40

            ColumnLayout {
                Layout.margins: 30
                Layout.fillHeight: true
                Layout.fillWidth: true

                Label {
                    text: "Watch tower" // Changed
                    color: "white"
                    font.pointSize: 28
                }

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 70

                    // Αριστερή στήλη
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 20

                        Label {
                            text: isChecking ? "Scanning vault..." : "Scan complete" // ΝΕΟ
                            color: isChecking ? "#7ADCB4" : "white"
                            font.pixelSize: 20
                        }

                        Rectangle {
                            id: nowCheckingItem
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 400
                            radius: 20
                            color: "#1E2634"
                            border.color: isChecking ? "#7ADCB4" : "white" // ΝΕΟ
                            border.width: 2
                            clip: true
                            
                            // Μπάρα φόρτωσης 
                            Rectangle { // ΝΕΟ: Animation φόρτωσης
                                height: parent.height - 10
                                width: isChecking ? parent.width - 20 : 0
                                radius: 15
                                color: "#303946"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                visible: isChecking
                                Behavior on width { NumberAnimation { duration: 1000 } }
                            }
                        }

                        Label {
                            text: "Password policy check:" // Changed
                            color: "white"
                            font.pixelSize: 20
                        }

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

                                // Δυναμική λίστα αποτελεσμάτων (αντί για checkboxes)
                                RowLayout {
                                    spacing: 15
                                    Image {
                                        // ΝΕΟ: Αλλάζει εικονίδιο αν βρεθούν αδύναμα passwords
                                        source: weakCount === 0 ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                        Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Label { text: "No weak passwords"; color: "white"; font.pixelSize: 18 } // Changed
                                }

                                RowLayout {
                                    spacing: 15
                                    Image {
                                        // ΝΕΟ: Αλλάζει εικονίδιο αν βρεθούν επαναλαμβανόμενα
                                        source: reusedCount === 0 ? "../imgs/checked_box.svg" : "../imgs/unchecked_box.svg"
                                        Layout.preferredHeight: 30; Layout.preferredWidth: 30
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Label { text: "No reused passwords"; color: "white"; font.pixelSize: 18 } // Changed
                                }
                                
                                Rectangle { Layout.fillWidth: true; height: 1; color: "gray"; opacity: 0.5 }
                                
                                Label { 
                                    text: "Stats found:" // Changed
                                    color: "#B5B5B5"
                                    font.pixelSize: 16 
                                }
                                // ΝΕΟ: Εμφανίζει τους αριθμούς
                                Label { text: "• " + weakCount + " weak passwords"; color: weakCount > 0 ? "#F76262" : "white"; font.pixelSize: 16 } // Changed
                                Label { text: "• " + reusedCount + " reused passwords"; color: reusedCount > 0 ? "#F76262" : "white"; font.pixelSize: 16 } // Changed
                                
                                Item { Layout.fillHeight: true }
                            }
                        }

                        Label {
                            text: "Exposed in data breaches?" // Changed
                            color: "white"
                            font.pixelSize: 20
                        }

                        // Κουτί breach (αλλάζει χρώμα σε κόκκινο αν υπάρχει πρόβλημα)
                        Rectangle {
                            id: exposedItemInBreach
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 400
                            radius: 20
                            // ΝΕΟ: Γίνεται κόκκινο (#381E1E) αν hasBreaches είναι true
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
                                    // ΝΕΟ: Αλλάζει το κείμενο δυναμικά
                                    text: hasBreaches ? "Warning: " + breachedCount + " breaches found!" : "All good. No breaches found." // Changed
                                    color: hasBreaches ? "#F65151" : "#7ADCB4"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // Δεξιά στήλη
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 20

                        Label {
                            text: isVaultStrong ? "Overall strength: Strong" : "Overall strength: Needs attention" // ΝΕΟ
                            color: isVaultStrong ? "#7ADCB4" : "#F65151"
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 300
                            radius: 20
                            color: isVaultStrong ? "#7ADCB4" : "#F65151" // ΝΕΟ
                            border.color: "white"
                            
                            Text {
                                anchors.centerIn: parent
                                text: isVaultStrong ? "Excellent" : "Weak" // ΝΕΟ
                                color: "#1E2634"
                                font.bold: true
                                font.pixelSize: 18
                            }
                        }

                        Label {
                            text: "Action required:" // Changed
                            color: "white"
                            font.pixelSize: 20
                        }

                        Rectangle {
                            Layout.preferredHeight: 350
                            Layout.preferredWidth: 400
                            radius: 20
                            color: "#1E2634"
                            border.color: "white"

                            ScrollView {
                                anchors.fill: parent
                                clip: true
                                
                                ColumnLayout {
                                    width: parent.width
                                    anchors.margins: 15
                                    spacing: 10
                                    
                                    // ΝΕΟ: Μηνύματα που εμφανίζονται μόνο αν υπάρχει πρόβλημα
                                    Text {
                                        visible: breachedCount > 0
                                        text: "Change " + breachedCount + " compromised passwords immediately."
                                        color: "#F65151"
                                        font.pixelSize: 16
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        Layout.margins: 10
                                    }
                                    
                                    Text {
                                        visible: weakCount > 0
                                        text: "Strengthen " + weakCount + " weak passwords."
                                        color: "#F29A7A" 
                                        font.pixelSize: 16
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        Layout.margins: 10
                                    }

                                    Text {
                                        visible: reusedCount > 0
                                        text: "You have " + reusedCount + " reused passwords."
                                        color: "#F29A7A" 
                                        font.pixelSize: 16
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        Layout.margins: 10
                                    }
                                    
                                    Text {
                                        visible: isVaultStrong
                                        text: "Great job! Your vault is secure."
                                        color: "#7ADCB4"
                                        font.pixelSize: 16
                                        Layout.margins: 10
                                    }
                                }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#161C26"
                radius: 25
            }
        }
    }
}
