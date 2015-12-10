import QtQuick 2.4
import "./"
import "levels.js" as Levels

Rectangle {
    id: root
    height: window.height
    width: height
    anchors.horizontalCenter: window.horizontalCenter
    y: 0
    visible: false
    color: "black"
    focus: true

    property bool isGame: false
    property bool processorProcessing: false

    SequentialAnimation {
        id: yAnimation
        running: true
        NumberAnimation { target: root; property: "y"; from: 1000; to: 0; duration: 5000 }
    }

    Component.onCompleted:
    {
        titleField.startTimer()
        //yAnimation.start()
    }

    Keys.onPressed: {
        if(yAnimation.running)
        {
            yAnimation.complete()
        }
        else if(event.key === Qt.Key_Down)
            if(tankSelector.state < 3)
                ++tankSelector.state;
            else
                tankSelector.state = 0;
        else if(event.key === Qt.Key_Up)
            if(tankSelector.state > 0)
                --tankSelector.state;
            else
                tankSelector.state = 3;
        else if(event.key === Qt.Key_Return)
        {
            if(!tankSelector.state)
                pageLoader.setSource("levelScreen.qml", {"twoPlayers":false})
            else if(tankSelector.state === 1)
                pageLoader.setSource("levelScreen.qml", {"twoPlayers":true})
            else if(tankSelector.state === 2)
                pageLoader.setSource("helpPage.qml")
            else if(tankSelector.state === 3)
                pageLoader.setSource("aboutScreen.qml")
        }
    }

    Field {
        id: titleField
        width:  0.8 * parent.width
        height: parent.height / 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height / 6

        tilesTypes: Levels.titleScreen
    }

    Tank
    {
        id: tankSelector
        property int state: 0

        type: -1
        rotation: 90
        anchors.right: onePlayer.left
        anchors.rightMargin: parent.width / 30
        anchors.verticalCenter: state === 0 ? onePlayer.verticalCenter : state === 1 ? twoPlayers.verticalCenter : state === 2 ? construction.verticalCenter : state === 3 ? about.verticalCenter : about.verticalCenter

        xMap: 0
        yMap: 0
    }

    Text {
        id: iScore
        width: parent.width / 20
        text: qsTr("I-")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: parent.left
            leftMargin: parent.height / 20
        }
    }
    Text {
        id: iMaxScore
        width: parent.width / 10
        text: pageLoader.playerOneHighScore.toString()
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: iScore.right
            leftMargin: 0
        }
    }

    Text {
        id: hiScore
        width: parent.width / 20
        text: qsTr("HI-")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: iMaxScore.right
            leftMargin: 20
        }
    }
    Text {
        id: hiScoreValue
        width: parent.width / 20
        text: settings.highScore.toString()
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: hiScore.right
            leftMargin: 20
        }
    }

    Text {
        id: iiScore
        width: parent.width / 20
        text: qsTr("II-")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: hiScoreValue.right
            leftMargin: 100
        }
    }
    Text {
        id: iiMaxScore
        width: parent.width / 10
        text: pageLoader.playerTwoHighScore.toString()
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: parent.top
            topMargin: parent.height / 15
            left: iiScore.right
            leftMargin: 0
        }
    }

    Text {
        id: onePlayer
        width: parent.width / 5
        text: qsTr("1 PLAYER")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: titleField.bottom
            topMargin: parent.height / 15
            left: hiScore.left
        }
    }
    Text {
        id: twoPlayers
        width: parent.width / 5
        text: qsTr("2 PLAYERS")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: onePlayer.bottom
            topMargin: parent.height / 60
            left: hiScore.left
        }
    }
    Text {
        id: construction
        width: parent.width / 5
        text: qsTr("HELP")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: twoPlayers.bottom
            topMargin: parent.height / 60
            left: hiScore.left
        }
    }
    Text {
        id: about
        width: parent.width / 5
        text: qsTr("ABOUT")
        font.pixelSize: parent.height / 30
        color: "white"

        anchors {
            top: construction.bottom
            topMargin: parent.height / 60
            left: hiScore.left
        }
    }
}

