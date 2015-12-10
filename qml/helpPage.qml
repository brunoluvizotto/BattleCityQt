import QtQuick 2.4

Rectangle
{
    id: rectanglePause
    height: window.height
    width: height
    anchors.centerIn: parent
    border.width: 4
    border.color: "black"
    //radius: width / 20
    color: "black"
    visible: true
    focus: true

    Keys.onPressed: {
        pageLoader.setSource("mainScreen.qml")
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: parent.height / 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        Text {
            text: "Controls"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "darkblue"
        }
        Text {
            text: "P1"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "#BBBB00"
        }
        Text {
            text: "Up: Key UP"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Down: Key Down"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Left: Key Left"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Right: Key Right"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Fire: Key 'M'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "P2"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "#007700"
        }
        Text {
            text: "Up: Key 'R'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Down: Key 'F'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Left: Key 'D'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Right: Key 'G'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            text: "Fire: Key 'Z'"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
        Text {
            id: pressAnyKeyText
            text: "PRESS ANY KEY TO RETURN"
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "white"
        }
    }
    Timer {
        id: timerPressKey
        running: true
        repeat: true
        interval: 500
        onTriggered: pressAnyKeyText.visible = !pressAnyKeyText.visible
    }
}
