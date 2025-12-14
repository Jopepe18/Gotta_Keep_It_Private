import QtQuick
import QtQuick.Controls
//το main.qml είναι για να συνδέονται οι αλλαγες μεταξυ των οθονών, για το stackview
Window {
    id: window
    width: 1500
    height: 1080
    visible: true
    title: qsTr("Gotta Keep It Private")

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: Login {
            onRegisterRequested: stackView.push(registerComponent)
        }

        Component {
            id: registerComponent
            Register {
                onLoginRequested: stackView.pop()
            }
        }
    }
}
