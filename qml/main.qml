import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import "./"

ApplicationWindow {
    id: window
    title: qsTr("Hello World")
    visible: true
    color: "black"
    visibility: "FullScreen"

    property string source: "mainScreen.qml"

    Item {
        id: container
        height: parent.height
        width: height
        anchors.centerIn: parent
        Loader {
            id: pageLoader
            width: parent.width
            height: parent.height
            focus: true
            source: window.source

            property int playerOneHighScore: 0
            property int playerTwoHighScore: 0
        }

        Component.onCompleted:
        {
        }
    }

}
