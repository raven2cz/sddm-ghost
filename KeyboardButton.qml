/*  
*   Modification made by l4k1 
*/

import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls 1.3 as QQC

PlasmaComponents.ToolButton {
    id: keyboardButton
    anchors {
        bottom: parent.bottom
        bottomMargin: 15
    }
    height: 30
    width: 30

    property int currentIndex: -1
    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", instantiator.objectAt(currentIndex).shortName)

    visible: menu.items.length > 1

    Component.onCompleted: currentIndex = Qt.binding(function() {return keyboard.currentLayout});

    menu: QQC.Menu {
        id: keyboardMenu
        Instantiator {
            id: instantiator
            model: keyboard.layouts
            onObjectAdded: keyboardMenu.insertItem(index, object)
            onObjectRemoved: keyboardMenu.removeItem( object )
            delegate: QQC.MenuItem {
                text: modelData.longName
                property string shortName: modelData.shortName
                onTriggered: {
                    keyboard.currentLayout = model.index
                }
            }
        }
    }
}
