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
        Component {
            id: changeForgotPasswordComponent
            ChangeForgotPassword {
                onChangePasswordSuccess: {
                    stackView.push(vaultRouterComponent)
                }
                onBackRequested: {
                    stackView.pop()
                }
            }
        }

        Component {
            id: forgotPasswordComponent
            ForgotPassword {
                onLoginRequested: {
                    stackView.pop()
                }
                onRecoveryVerified: function(username, key) {
                    // Instantiate component programmatically to pass properties or use push with properties if supported
                    // For simplicity in StackView push:
                    stackView.push(changeForgotPasswordComponent, {"username": username, "secretKey": key})
                }
            }
        }

        initialItem: 

        
        loadMainScreenComponent
            SideMenu {
                onLogoutClicked: stackView.pop(null) //Pop to root (Login)
            }


      /*
        Login {
            onRegisterRequested: {
                stackView.push(registerComponent)
            }
            onLoginSuccess: {
                stackView.push(vaultRouterComponent)
            }
            onForgotPasswordRequested: {
                stackView.push(forgotPasswordComponent)
            }
        }*/

        Component {
            id: registerComponent
            Register {
                onLoginRequested: stackView.pop()
                onRegisterSuccess: {
                    stackView.push(secretKeyComponent, {secretKey: key})
                }
            }
        }

        Component {
            id: secretKeyComponent
            SecretKeyScreen {
                onContinueClicked: stackView.push(vaultRouterComponent)
            }
        }

        Component {
            id: vaultRouterComponent
            VaultRouterScreen {
                onLogoutClicked: stackView.pop(null) // Pop to root (Login)
                onLoadMain: stackView.push(loadMainScreenComponent)
            }
        }

        Component{
            id: loadMainScreenComponent
            SideMenu {
                onLogoutClicked: stackView.pop(null) //Pop to root (Login)
            }
        }

    }
}
