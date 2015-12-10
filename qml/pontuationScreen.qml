import QtQuick 2.4
import "./"

Rectangle {
    anchors.fill: parent
    focus: true
    property var enemiesKilled: [0, 0, 0, 0]
    property var enemiesKilledTwo: [0, 0, 0, 0]
    property bool playerOneWon: false
    property bool playerTwoWon: false

    property int killsOne: 0
    property int killsTwo: 0
    property int killsThree: 0
    property int killsFour: 0

    property int killsOneTwo: 0
    property int killsTwoTwo: 0
    property int killsThreeTwo: 0
    property int killsFourTwo: 0

    property int totalPontuation: ((enemiesKilled[0] * 100 + enemiesKilled[1] * 200 + enemiesKilled[2] * 300 + enemiesKilled[3] * 400) + 500 * playerOneWon) + ((enemiesKilledTwo[0] * 100 + enemiesKilledTwo[1] * 200 + enemiesKilledTwo[2] * 300 + enemiesKilledTwo[3] * 400) + 500 * playerTwoWon)
    property int playerOneTotal: ((enemiesKilled[0] * 100 + enemiesKilled[1] * 200 + enemiesKilled[2] * 300 + enemiesKilled[3] * 400) + 500 * playerOneWon)
    property int playerTwoTotal: twoPlayers ? ((enemiesKilledTwo[0] * 100 + enemiesKilledTwo[1] * 200 + enemiesKilledTwo[2] * 300 + enemiesKilledTwo[3] * 400) + 500 * playerTwoWon) : 0

    property bool finishedPontuation: false
    property bool twoPlayers: false

    color: "black"

    Component.onCompleted:
    {
        if(!(enemiesKilled[0] + enemiesKilled[1] + enemiesKilled[2] + enemiesKilled[3]))
            finishedPontuation = true
        if (totalPontuation > settings.highScore)
        {
            settings.highScore = totalPontuation
            newHighScore.visible = true
        }
        playerOneHighScore = playerOneTotal
        playerTwoHighScore = playerTwoTotal
    }

    Keys.onPressed: {
        if(enemiesKilled[0] + enemiesKilled[1] + enemiesKilled[2] + enemiesKilled[3] + enemiesKilledTwo[0] + enemiesKilledTwo[1] + enemiesKilledTwo[2] + enemiesKilledTwo[3])
        {
            processNextSum.interval = 10
        }
        else
        {
            if(event.key === Qt.Key_Space)
                pageLoader.setSource("mainScreen.qml")
        }
    }

    Image {
        id: onePlayerPontuationImage
        width: 2 * parent.width / 3
        height: parent.height / 2
        source: twoPlayers ? "qrc:/Images/pontuationTwoPlayers.png" : "qrc:/Images/pontuationOnePlayer.png"
        fillMode: Image.Stretch
        anchors.centerIn: parent
    }

    Text {
        id: onePlayerPontuationTotal
        width: parent.width / 5
        text: playerOneTotal.toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "Orange"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 6
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8
        }
    }

    Text {
        id: twoPlayerPontuationTotal
        width: parent.width / 5
        text: playerTwoTotal.toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "Orange"
        visible: twoPlayers

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 6
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 2
        }
    }

    Timer {
        id: processNextSum
        interval: 500
        running: enemiesKilled[0] + enemiesKilled[1] + enemiesKilled[2] + enemiesKilled[3] + enemiesKilledTwo[0] + enemiesKilledTwo[1] + enemiesKilledTwo[2] + enemiesKilledTwo[3]
        repeat: enemiesKilled[0] + enemiesKilled[1] + enemiesKilled[2] + enemiesKilled[3] + enemiesKilledTwo[0] + enemiesKilledTwo[1] + enemiesKilledTwo[2] + enemiesKilledTwo[3]
        onTriggered:
        {
            if(enemiesKilled[0])
            {
                ++killsOne
                --enemiesKilled[0]
            }
            else if(enemiesKilledTwo[0])
            {
                ++killsOneTwo
                --enemiesKilledTwo[0]
            }
            else if(enemiesKilled[1])
            {
                ++killsTwo
                --enemiesKilled[1]
            }
            else if(enemiesKilledTwo[1])
            {
                ++killsTwoTwo
                --enemiesKilledTwo[1]
            }
            else if(enemiesKilled[2])
            {
                ++killsThree
                --enemiesKilled[2]
            }
            else if(enemiesKilledTwo[2])
            {
                ++killsThreeTwo
                --enemiesKilledTwo[2]
            }
            else if(enemiesKilled[3])
            {
                ++killsFour
                --enemiesKilled[3]
            }
            else if(enemiesKilledTwo[3])
            {
                ++killsFourTwo
                --enemiesKilledTwo[3]
            }
            else
            {
                finishedPontuation = true
                processNextSum.stop()
            }
        }
    }

    Text {
        id: pontuationLevelOne
        text: (killsOne * 100).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 20.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 2.6
        }
    }
    Text {
        id: pontuationLevelOneTwo
        text: (killsOneTwo * 100).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 20.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 4
        }
    }

    Text {
        id: killsLevelOne
        text: (killsOne * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 20.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8.5
        }
    }
    Text {
        id: killsLevelOneTwo
        text: (killsOneTwo * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: - onePlayerPontuationImage.height / 20.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 8.5
        }
    }

    Text {
        id: pontuationLevelTwo
        text: (killsTwo * 200).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 13.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 2.6
        }
    }
    Text {
        id: pontuationLevelTwoTwo
        text: (killsTwoTwo * 200).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 13.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 4
        }
    }

    Text {
        id: killsLevelTwo
        text: (killsTwo * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 13.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8.5
        }
    }
    Text {
        id: killsLevelTwoTwo
        text: (killsTwoTwo * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 13.5
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 8.5
        }
    }

    Text {
        id: pontuationLevelThree
        text: (killsThree * 300).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 5.1
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 2.6
        }
    }
    Text {
        id: pontuationLevelThreeTwo
        text: (killsThreeTwo * 300).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 5.1
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 4
        }
    }

    Text {
        id: killsLevelThree
        text: (killsThree * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 5.1
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8.5
        }
    }
    Text {
        id: killsLevelThreeTwo
        text: (killsThreeTwo * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 5.1
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 8.5
        }
    }

    Text {
        id: pontuationLevelFour
        text: (killsFour * 400).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 3.12
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 2.6
        }
    }
    Text {
        id: pontuationLevelFourTwo
        text: (killsFourTwo * 400).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 3.12
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 4
        }
    }

    Text {
        id: killsLevelFour
        text: (killsFour * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 3.12
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8.5
        }
    }
    Text {
        id: killsLevelFourTwo
        text: (killsFour * 1).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 3.12
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 8.5
        }
    }

    Text {
        id: killsTotal
        text: (killsOne + killsTwo + killsThree + killsFour).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 2.46
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: - onePlayerPontuationImage.width / 8.5
        }
    }
    Text {
        id: killsTotalTwo
        text: (killsOneTwo + killsTwoTwo + killsThreeTwo + killsFourTwo).toString()
        font.pixelSize: onePlayerPontuationImage.height / 18
        color: "White"
        horizontalAlignment: Text.AlignRight
        visible: text !== "0"

        anchors {
            verticalCenter: onePlayerPontuationImage.verticalCenter
            verticalCenterOffset: onePlayerPontuationImage.height / 2.46
            horizontalCenter: onePlayerPontuationImage.horizontalCenter
            horizontalCenterOffset: + onePlayerPontuationImage.width / 8.5
        }
    }

    Text {
        id: pressAnyKeyText
        text: "Press space to continue"
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height / 3.3
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "orange"
    }

    Timer {
        id: timerPressAnyKey
        running: finishedPontuation
        repeat: finishedPontuation
        interval: 700
        onTriggered: pressAnyKeyText.visible = !pressAnyKeyText.visible
    }

    Text {
        id: newHighScore
        text: "New highscore!"
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height / 4
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "red"
    }
}

