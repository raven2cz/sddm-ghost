/*  
*   Modification made by l4k1 
*/

import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SessionManagementScreen {

    property bool showUsernamePrompt: !showUserList

    signal loginRequest(string username, string password)

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focussed
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    Rectangle {
        id: userAvatarBlock
        Layout.fillWidth: true
        Layout.minimumHeight: 200
        Layout.maximumHeight: 200
        Layout.topMargin: -380
        color: "transparent"
        Image {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit
            source: "components/artwork/user.png"
            width: 200
            height: 200
        }
    }

    Rectangle {
        id: userNameBlock
        Layout.fillWidth: true
        Layout.minimumHeight: 70
        Layout.maximumHeight: 70
        Layout.topMargin: -80
        Layout.rightMargin:-10
        Layout.leftMargin:-10
        color: "transparent"
        Text {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            text: userList.selectedUser
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 28
            color: "White"
        }
    }

    PlasmaComponents.TextField {
        id: userNameInput
        Layout.fillWidth: true
        Layout.minimumHeight: 40
        Layout.maximumHeight: 40
        Layout.rightMargin:-10
        Layout.leftMargin:-10

        visible: showUsernamePrompt
        focus: showUsernamePrompt //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")
    }

    PlasmaComponents.TextField {
        id: passwordBox
        Layout.fillWidth: true
        Layout.minimumHeight: 40
        Layout.maximumHeight: 40
        Layout.rightMargin: 26
        Layout.leftMargin:-10

        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt
        echoMode: TextInput.Password
        revealPasswordButtonShown: true

        onAccepted: startLogin()

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        //if empty and left or right is pressed change selection in user switch
        //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }
    }

    Rectangle {
        id: loginButton
        Layout.minimumWidth: 40
        Layout.maximumWidth: 40
        Layout.minimumHeight: 40
        Layout.maximumHeight: 40

        anchors {
            right: passwordBox.right
            rightMargin: -37
            verticalCenter: passwordBox.verticalCenter
        }

        color: "#7171a8"
        radius: 2

        Image {
            height: 36
            width: 36

            anchors {
                top: loginButton.top
                right: loginButton.right
                verticalCenter: parent.verticalCenter
            }

            source: "components/artwork/login_primary.svgz"
            smooth: true

            MouseArea {
                anchors.fill: parent
                onClicked: startLogin();
            }
        }

    }
}
