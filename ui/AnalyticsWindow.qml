import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Shapes 1.15

Window {
    id: root
    width: 950
    height: 650
    title: "Vault Analytics"
    color: "#1E2634"
    modality: Qt.ApplicationModal

    // ΔΕΔΟΜΕΝΑ UI (ΓΙΑ ΤΑ ΚΕΙΜΕΝΑ)
    property int weakCount: 0
    property int reusedCount: 0
    property int breachedCount: 0
    property int totalItems: 1
    // ΔΕΔΟΜΕΝΑ ΓΡΑΦΗΜΑΤΟΣ
    property int graphWeak: 0
    property int graphReused: 0
    property int graphBreached: 0
    property int graphSafe: 0
    // --- 3. ΥΠΟΛΟΓΙΣΜΟΣ ΠΟΣΟΣΤΩΝ (Βάσει Graph Stats) ---
    property real safePct: graphSafe / (totalItems > 0 ? totalItems : 1)
    property real weakPct: graphWeak / (totalItems > 0 ? totalItems : 1)
    property real reusedPct: graphReused / (totalItems > 0 ? totalItems : 1)
    property real breachedPct: graphBreached / (totalItems > 0 ? totalItems : 1)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            text: "Security Snapshot"
            color: "white"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // --- TABS ---
        TabBar {
            id: bar
            width: parent.width
            Layout.fillWidth: true
            background: Rectangle { color: "transparent" }

            TabButton {
                text: "Composition"
                contentItem: Text { text: parent.text; font.bold: true; color: parent.checked ? "#7ADCB4" : "gray"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.checked ? "#303946" : "transparent"; radius: 10 }
            }
            TabButton {
                text: "Bar Chart"
                contentItem: Text { text: parent.text; font.bold: true; color: parent.checked ? "#7ADCB4" : "gray"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.checked ? "#303946" : "transparent"; radius: 10 }
            }
        }

        SwipeView {
            id: view
            currentIndex: bar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // --- TAB 1: PIE CHART ---
            Item {
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 50

                    // A. ΤΟ ΓΡΑΦΗΜΑ (Canvas)
                    Item {
                        width: 300; height: 300
                        
                        Canvas {
                            id: pieCanvas
                            anchors.fill: parent
                            antialiasing: true
                            
                            onPaint: {
                                var ctx = getContext("2d");
                                var cx = width / 2;
                                var cy = height / 2;
                                var radius = (width / 2) - 20;
                                var lineWidth = 35;
                                
                                ctx.reset();
                                ctx.lineCap = "butt";
                                ctx.lineWidth = lineWidth;

                                var startAngle = -Math.PI / 2; // Ξεκινάμε από πάνω (12 η ώρα)

                                function drawSlice(pct, color) {
                                    if (pct <= 0.001) return; // Μην ζωγραφίζεις ανύπαρκτα κομμάτια
                                    var sliceAngle = pct * 2 * Math.PI;
                                    ctx.beginPath();
                                    ctx.strokeStyle = color;
                                    ctx.arc(cx, cy, radius, startAngle, startAngle + sliceAngle);
                                    ctx.stroke();
                                    startAngle += sliceAngle;
                                }

                                // Ζωγραφίζουμε με βάση τα ΠΟΣΟΣΤΑ ΠΡΟΤΕΡΑΙΟΤΗΤΑΣ
                                drawSlice(root.safePct, "#7ADCB4");     // Πράσινο
                                drawSlice(root.weakPct, "#F29A7A");     // Πορτοκαλί
                                drawSlice(root.reusedPct, "#F2CA7A");   // Κίτρινο
                                drawSlice(root.breachedPct, "#F65151"); // Κόκκινο
                            }
                            
                            // --- FIX ΓΙΑ ΤΟ BLACK GRAPH ---
                            // Ξαναζωγραφίζουμε όταν αλλάξει ΟΠΟΙΑΔΗΠΟΤΕ τιμή
                            Connections { 
                                target: root
                                function onTotalItemsChanged() { pieCanvas.requestPaint() }
                                function onGraphWeakChanged() { pieCanvas.requestPaint() }
                                function onGraphReusedChanged() { pieCanvas.requestPaint() }
                                function onGraphBreachedChanged() { pieCanvas.requestPaint() }
                                function onGraphSafeChanged() { pieCanvas.requestPaint() }
                            }
                        }

                        // Κείμενο στη μέση (Ποσοστό Ασφαλείας)
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Label { 
                                text: Math.round(root.safePct * 100) + "%"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 48
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label { 
                                text: "Secure"
                                color: "#B5B5B5"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // B. ΤΟ LEGEND (Επεξήγηση)
                    ColumnLayout {
                        spacing: 20
                        Layout.alignment: Qt.AlignVCenter

                        // ΕΔΩ ΕΙΝΑΙ ΤΟ ΚΟΛΠΟ:
                        // count: Δείχνουμε το REAL count (όλη την αλήθεια)
                        // pct: Δείχνουμε το GRAPH pct (για να ταιριάζει με την πίτα)
                        
                        LegendItem { colorCode: "#F65151"; label: "Breached"; count: root.graphBreached; pct: root.breachedPct }
                        LegendItem { colorCode: "#F2CA7A"; label: "Reused"; count: root.graphReused; pct: root.reusedPct }
                        LegendItem { colorCode: "#F29A7A"; label: "Weak"; count: root.graphWeak; pct: root.weakPct }
                        LegendItem { colorCode: "#7ADCB4"; label: "Safe"; count: root.graphSafe; pct: root.safePct }
                        
                        Rectangle { Layout.fillWidth: true; height: 1; color: "gray"; opacity: 0.3 }
                        
                        Text { text: "Total Items: " + root.totalItems; color: "white"; font.pixelSize: 18; font.bold: true }
                    }
                }
            }

            // --- TAB 2: BAR CHART ---
            Item {
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 40
                    
                    // Εδώ χρησιμοποιούμε τα REAL counts για να συγκρίνουμε μεγέθη
                    ChartBar { label: "Safe"; value: root.graphSafe; maxValue: root.totalItems; barColor: "#7ADCB4" }
                    ChartBar { label: "Breached"; value: root.breachedCount; maxValue: root.totalItems; barColor: "#F65151" }
                    ChartBar { label: "Reused"; value: root.reusedCount; maxValue: root.totalItems; barColor: "#F2CA7A" }
                    ChartBar { label: "Weak"; value: root.weakCount; maxValue: root.totalItems; barColor: "#F29A7A" }
                    
                }
            }
        }

        Button {
            text: "Close"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 150; Layout.preferredHeight: 45
            background: Rectangle { color: "#303946"; radius: 10; border.color: "white" }
            contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: root.close()
        }
    }

    // --- CUSTOM COMPONENTS ---

    component LegendItem : RowLayout {
        property string colorCode: "white"
        property string label: ""
        property int count: 0
        property real pct: 0.0
        spacing: 15
        
        Rectangle { width: 15; height: 15; radius: 5; color: colorCode }
        Label { text: label; color: "white"; font.pixelSize: 18; Layout.preferredWidth: 100 }
        
        // Ο Αριθμός (Real Count)
        Label { text: count.toString(); color: "white"; font.bold: true; font.pixelSize: 18; Layout.preferredWidth: 40 }
        
        // Το Ποσοστό (Priority %)
        Label { text: "(" + Math.round(pct*100) + "%)"; color: "#B5B5B5"; font.pixelSize: 16 }
    }

    component ChartBar : ColumnLayout {
        property string label: ""
        property int value: 0
        property int maxValue: 1
        property color barColor: "white"
        spacing: 10
        Layout.preferredHeight: 300 // Fixed height
        Layout.preferredWidth: 80
        
        Item {
            Layout.fillHeight: true; Layout.fillWidth: true
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                // Scale height based on max value
                height: (value / (maxValue > 0 ? maxValue : 1)) * 250 
                color: barColor
                radius: 5
                
                // Animation
                Behavior on height { NumberAnimation { duration: 1000; easing.type: Easing.OutBounce } }
            }
        }
        
        Label { text: value.toString(); color: "white"; font.bold: true; Layout.alignment: Qt.AlignHCenter }
        Label { text: label; color: "#B5B5B5"; Layout.alignment: Qt.AlignHCenter }
    }
}