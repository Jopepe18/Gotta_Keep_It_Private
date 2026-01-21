import QtQuick
import QtQuick.Controls
//το main.qml είναι για να συνδέονται οι αλλαγες μεταξυ των οθονών, για το stackview
Window {
    id: window
    width: 1500
    height: 1080
    visible: true
    title: qsTr("Gotta Keep It Private")
    property string currentUserId: ""
    property string currentTempPassword: "" // Store for vault creation
    property bool userHasVault: false

    StackView {
        id: stackView
        anchors.fill: parent
        Component {
            id: changeForgotPasswordComponent
            ChangeForgotPassword {
                onChangePasswordSuccess: function(userId, hasVault, newPassword) {
                    // Update global state with recovered credentials
                    window.currentUserId = userId
                    window.userHasVault = hasVault
                    window.currentTempPassword = newPassword
                    console.log("Main: Password recovered. User ID set to " + userId + ", HasVault=" + hasVault)
                    
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
        
        Login {
            onRegisterRequested: {
                stackView.push(registerComponent)
            }
            onLoginSuccess: function(secretKey, userId, hasVault, password) {
                // Set Global User ID and Vault State
                window.currentUserId = userId
                window.userHasVault = hasVault
                window.currentTempPassword = password
                console.log("Main: User ID set to " + userId + ", HasVault=" + hasVault)
                
                // Navigate
                stackView.push(vaultRouterComponent)
            }
            onForgotPasswordRequested: {
                stackView.push(forgotPasswordComponent)
            }
        }
        
        Component {
            id: registerComponent
            Register {
                onLoginRequested: stackView.pop()
                onRegisterSuccess: function(key, userId, password) {
                     window.currentUserId = userId
                     window.userHasVault = false // New users don't have vaults
                     window.currentTempPassword = password
                     console.log("Main: User ID set to " + userId)
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
                userIdString: window.currentUserId
                vaultPassword: window.currentTempPassword
                hasExistingVault: window.userHasVault
                onLogoutClicked: stackView.pop(null) // Pop to root (Login)
                onLoadMain: stackView.push(loadMainScreenComponent)
            }
        }

        Component{
            id: loadMainScreenComponent
            SideMenu {
                userIdString: window.currentUserId
                masterPassword: window.currentTempPassword
                onLogoutClicked: {
                    stackView.pop(null) //Pop to root (Login)
                stackView.currentItem.emptyFields()
                }
            }
        }

    }
}
