/*  
*   Modification made by l4k1 
*/

/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "components"

PlasmaCore.ColorScope {
    id: root
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Timer {
        id: coverTimer
        interval: 30000 // set the interval you want the cover to appear default is 30 seconds
        onTriggered: {
            if (cover.state == "hidden") {
                cover.state = "visible"
                cover.forceActiveFocus()
            }
        }
    }

    Keys.onEscapePressed: {
        if (cover.state == "hidden") {
            cover.state = "visible"
            cover.forceActiveFocus()
        }
    }

    // hide the cover when a key is pressed
    Keys.onPressed: {
        coverTimer.restart()
        if (cover.state == "visible") {
            cover.state = "hidden"
            mainStack.forceActiveFocus()
        }
    }

    Rectangle {
        anchors {
            fill: parent
        }
        color: "#7171a8"
    }
    
    Image {
        anchors {
            fill: parent
        }
        clip: true
        focus: true
        smooth: true
        source: config.background
    }

    Rectangle {
        anchors {
            fill: parent
        }
        color: "#1a1a26"
        opacity: 0.3
    }
    
    PlasmaComponents.ToolButton {
        id: keyboardIcon
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 10
            rightMargin: 10
        }
        height: 30
        width: 30
        iconName: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
        onClicked: { 
            inputPanel.showHide() 
            keyboardBackground.showHide()
            keyboardIcon.showHide()
        }
    }

    StackView {
        id: mainStack
        anchors {
            top: parent.top
            bottom: footer.top
            left: parent.left
            right: parent.right
            topMargin: footer.height // effectively centre align within the view
        }
        focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

        Timer {
            //SDDM has a bug in 0.13 where even though we set the focus on the right item within the window, the window doesn't have focus
            //it is fixed in 6d5b36b28907b16280ff78995fef764bb0c573db which will be 0.14
            //we need to call "window->activate()" *After* it's been shown. We can't control that in QML so we use a shoddy timer
            //it's been this way for all Plasma 5.x without a huge problem
            running: true
            repeat: false
            interval: 200
            onTriggered: cover.forceActiveFocus()
        }

        initialItem: Login {
            id: userListComponent
            userListModel: userModel
            userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            showUserList: {
                 if ( !userListModel.hasOwnProperty("count")
                   || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                     return true

                 if ( userListModel.count == 0 ) return false

                 return userListModel.count <= userListModel.disableAvatarsThreshold
            }

            notificationMessage: {
                var text = ""
                if (keystateSource.data["Caps Lock"]["Locked"]) {
                    text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                    if (root.notificationMessage) {
                        text += " • "
                    }
                }
                text += root.notificationMessage
                return text
            }

            actionItems: [
                SessionButton {
                    id: sessionButton
                },
                KeyboardButton {
                    
                },
                Battery { 
                    
                },
                ActionButton {
                    iconSource: "system-switch-user"
                    onClicked: mainStack.push(userPromptComponent)
                    enabled: true
                    visible: !userListComponent.showUsernamePrompt
                },
                ActionButton {
                    iconSource: "system-suspend"
                    onClicked: sddm.suspend()
                    enabled: sddm.canSuspend
                },
                ActionButton {
                    iconSource: "system-reboot"
                    onClicked: sddm.reboot()
                    enabled: sddm.canReboot
                },
                ActionButton {
                    iconSource: "system-shutdown"
                    onClicked: sddm.powerOff()
                    enabled: sddm.canPowerOff
                }
            ]

            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
            }
            
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }
    }
    
    Component {
        id: userPromptComponent
        Login {
            Rectangle {
                anchors {
                    bottom: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                Layout.fillWidth: true
                Layout.minimumHeight: 75
                Layout.maximumHeight: 75
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
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Different User")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 22
                    color: "white"
                }
            }

            showUsernamePrompt: true
            notificationMessage: {
                var text = ""
                if (keystateSource.data["Caps Lock"]["Locked"]) {
                    text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                    if (root.notificationMessage) {
                        text += " • "
                    }
                }
                text += root.notificationMessage
                return text
            }

            userListModel: QtObject {
                property string iconSource: ""
            }

            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
            }

            actionItems: [
                SessionButton {
                    id: sessionButton
                },
                KeyboardButton {
                    
                },
                Battery { 
                    
                },
                ActionButton {
                    iconSource: "system-users"
                    onClicked: mainStack.pop()
                },
                ActionButton {
                    iconSource: "system-suspend"
                    onClicked: sddm.suspend()
                    enabled: sddm.canSuspend
                },
                ActionButton {
                    iconSource: "system-reboot"
                    onClicked: sddm.reboot()
                    enabled: sddm.canReboot
                },
                ActionButton {
                    iconSource: "system-shutdown"
                    onClicked: sddm.powerOff()
                    enabled: sddm.canPowerOff
                }
            ]
        }
    }
    
    Rectangle {
        id: keyboardBackground
        state: "hidden"
        function showHide() {
            state = state == "hidden" ? "visible" : "hidden";
        }
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 470
        color: "transparent"
            
        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: keyboardBackground
                    opacity: 1
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: keyboardBackground
                    opacity: 0
                }
            }
        ]
    
        Loader {
            id: inputPanel
            state: "hidden"
            readonly property bool keyboardActive: item ? item.active : false
            anchors {
                left: parent.left
                leftMargin: 450
                right: parent.right
                rightMargin: 450
                bottom: parent.bottom
            }
            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }
            Component.onCompleted: inputPanel.source = "components/VirtualKeyboard.qml"
            
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: inputPanel
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: inputPanel
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }
    }

    //Footer
    RowLayout {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: units.smallSpacing
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    Rectangle {
        id: cover
        focus: true
        state: "visible"
        function showHide() {
            state = state == "visible" ? "visible" : "hidden";
        }
        x: 0
        y: 0
        z: 100
        width: parent.width
        height: parent.height
        
        Image {
            anchors {
                fill: parent
            }
            clip: true
            focus: true
            smooth: true
            source: config.background

            Clock {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: units.gridUnit * 6
                anchors.left: parent.left
                anchors.leftMargin: units.gridUnit * 3
            }
        }

        Rectangle {
            anchors {
                fill: parent
            }
            color: "#1a1a26"
            opacity: 0.1
        }

        Keys.onPressed: {
            if (cover.state == "visible") {
                cover.state = "hidden"
                mainStack.forceActiveFocus()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: { coverTimer.restart(); cover.state = "hidden"; mainStack.forceActiveFocus() }
        }

        states: [
            State {
                name: "visible"
                PropertyChanges { target: cover; y: 0; z: 100; opacity: 1 }
            },
            State {
                name: "hidden"
                PropertyChanges { target: cover; y: - parent.height; z: 0; opacity: 0.6 }
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "hidden"
                NumberAnimation { properties: "y,opacity"; duration: 900; easing.type: Easing.OutExpo }
            },
            Transition {
                from: "*"; to: "visible"
                NumberAnimation { properties: "y,opacity"; duration: 900; easing.type: Easing.InExpo }
            }
        ]
    }

    Connections {
        target: sddm
        onLoginFailed: {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
        onLoginSucceeded: {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }

}
