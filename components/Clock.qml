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

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0

//http://doc.qt.io/qt-5/qml-qtqml-date.html

ColumnLayout {

        Label {
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: -25
                bottomMargin: 70
            }
            text: Qt.formatTime(timeSource.data["Local"]["DateTime"], "hh:mm:ss")
            font.pointSize: 45
            font.weight: Font.Light
            Layout.alignment: Qt.AlignLeft
        }

        Label {
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: -20
                bottomMargin: 30
            }
            text: Qt.formatDateTime(new Date(),"dddd MMMM d yyyy")
            font.pointSize: 22
            font.weight: Font.Dark
            Layout.alignment: Qt.AlignLeft
        }

        DataSource {
            id: timeSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 1000
        }
}
