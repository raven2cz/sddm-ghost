/*  
*   Modification made by l4k1 
*/

/*
 *   Copyright 2016 Kai Uwe Broulik <kde@privat.broulik.de>
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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PW

Row {
    spacing: units.smallSpacing

    anchors {
        bottom: parent.bottom
        bottomMargin: 15
    }
    
    visible: pmSource.data["Battery"]["Has Cumulative"]

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }
    
//     PlasmaComponents.Label {
//         id: batteryLabel
//         height: 65
//         text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","%1%", battery.percent)
//     }

    PW.BatteryIcon {
        id: battery
        height: 50
        width: 50
        hasBattery: true
        percent: pmSource.data["Battery"]["Percent"]
        pluggedIn: pmSource.data["AC Adapter"] ? pmSource.data["AC Adapter"]["Plugged in"] : false
    }
}
