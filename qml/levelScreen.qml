import QtQuick 2.4
import QtMultimedia 5.4
import "./"
import "levels.js" as Levels

Rectangle {
    id: border
    anchors.fill: parent
    color: "black"
    focus: true
    property bool levelVisible: false
    property int onePlayerLife: 2
    property int twoPlayerLife: 2
    property int enemiesLife: 20
    property var enemiesKilled: [0, 0, 0, 0]
    property var enemiesKilledTwo: [0, 0, 0, 0]
    property bool firstAnimationFinished: false
    property bool twoPlayers: false
    property bool playerOneDead: false
    property bool playerTwoDead: false
    property real specialEnemyProb: 0.1
    property bool specialEnemyExists: false

    Keys.onPressed: {
        if(levelVisible)
        {
            animation2.start()
        }
        if(!event.isAutoRepeat)
        {
            if(event.key === Qt.Key_P)
            {
                if(processor.isProcessing)
                {
                    processor.isProcessing = false
                    pauseText.visible = true
                }
                else
                {
                    processor.isProcessing = true
                    pauseText.visible = false
                }
            }
        }
    }

    Component.onCompleted:
    {
        levelField.startTimer()
    }

    Timer {
        id: loading
        running: true
        interval: 300
        onTriggered: animation1.start()
    }

    Rectangle {
        anchors.fill: parent
        color: "#535353"
        visible: levelVisible
    }

    Rectangle {
        id: levelRectangle
        anchors {
            fill: parent
            topMargin: 50
            leftMargin: 50
            bottomMargin: 50
            rightMargin: 100
        }
        color: "black"

        Field {
            id: levelField
            width:  parent.width
            height: parent.height
            visible: levelVisible

            tilesTypes: Levels.levelOne
            property bool isGame: true
            property bool canCreateEnemy: !tankEnemyOne.visible || !tankEnemyTwo.visible || !tankEnemyThree.visible || !tankEnemyFour.visible
            property bool processorProcessing: processor.isProcessing

            onProcessorProcessingChanged:
            {
                if(processorProcessing)
                    tankEnemyOneEngineSound.play()
                else
                    tankEnemyOneEngineSound.stop()

            }

            function playerOneDelBullet(player)
            {
                if(player === 1)
                    --tankPlayerOne.simultaneousBullets;
                else if(player === 2)
                    --tankPlayerTwo.simultaneousBullets;
                else if(player === 3)
                    --tankEnemyOne.simultaneousBullets;
                else if(player === 4)
                    --tankEnemyTwo.simultaneousBullets;
                else if(player === 5)
                    --tankEnemyThree.simultaneousBullets;
                else if(player === 6)
                    --tankEnemyFour.simultaneousBullets;
            }

            function activateEnemyTimer()
            {
                createNewEnemy.restart()
            }

            BasePlayerOne
            {
                id: basePlayerOne
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height - 8 * parent.blockHeight

                onVisibleChanged:
                {
                    if(!basePlayerOne.visible && firstAnimationFinished)
                    {
                        processor.isProcessing = false
                        parent.processorProcessing = false
                        timerPlayerOneLost.restart()
                        //player one lose
                    }
                }

                Timer
                {
                    id: timerPlayerOneLost
                    running: false
                    repeat: false
                    interval: 2000
                    onTriggered: pageLoader.setSource("pontuationScreen.qml", {"enemiesKilled":border.enemiesKilled, "enemiesKilledTwo":border.enemiesKilledTwo, "playerOneWon":!border.playerOneDead, "playerTwoWon":!border.playerTwoDead, "twoPlayers":border.twoPlayers})
                }
            }

            Tank {
                id: tankPlayerOne
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !processor.moving || !parent.processorProcessing
                playing: processor.moving && parent.processorProcessing
                speed: level === 0 ? 7 : level === 1 ? 10 : 10
                type: 0
                player: 1
                x: 4 + 8 * parent.width / 26
                y: 6 + 24 * parent.height / 26

                onPlayingChanged:
                {
                    if(playing)
                        tankOneEngineSound.play()
                    else
                        tankOneEngineSound.stop()
                }

                signal noMoreLife()

                onNoMoreLife:
                {
                    border.playerOneDead = true
                    if(border.playerTwoDead || !border.twoPlayers)
                    {
                        processor.isProcessing = false
                        parent.processorProcessing = false
                        timerPlayerOneLost.restart()
                    }
                }

                function died()
                {
                    if(border.onePlayerLife)
                    {
                        level = 0;
                        --border.onePlayerLife
                        waitAnimation.restart()
                    }
                    else
                    {
                        noMoreLife()
                    }
                }

                Timer
                {
                    id: waitAnimation
                    interval: 2000
                    running: false
                    repeat: false
                    onTriggered:
                    {
                        tankPlayerOne.rotation = 0
                        tankPlayerOne.x = 4 + 8 * levelField.width / 26
                        tankPlayerOne.y = 6 + 24 * levelField.height / 26
                        revivePlayerOne.restart()
                    }
                }

                Timer
                {
                    id: revivePlayerOne
                    interval: 1000
                    running: false
                    repeat: false
                    onTriggered:
                    {
                        tankPlayerOne.visible = true
                    }
                }

                SoundEffect {
                    id: tankOneEngineSound
                    volume: .45
                    source: "qrc:/Audio/tankOne.wav"
                    loops: SoundEffect.Infinite
                }

            }

            Tank {
                id: tankPlayerTwo
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !processor.movingTwo || !parent.processorProcessing
                playing: processor.movingTwo && parent.processorProcessing
                speed: level === 0 ? 7 : level === 1 ? 10 : 10
                type: 0
                player: 2
                x: 4 + 16 * parent.width / 26
                y: 6 + 24 * parent.height / 26
                source: level === 0 ? "qrc:/Images/playerTwo.gif" : level === 1 ? "qrc:/Images/playerTwoL2.gif" : "qrc:/Images/playerTwoL2.gif"
                visible: border.twoPlayers

                onPlayingChanged:
                {
                    if(playing && border.twoPlayers)
                        tankTwoEngineSound.play()
                    else
                        tankTwoEngineSound.stop()
                }

                signal noMoreLife()

                onNoMoreLife:
                {
                    border.playerTwoDead = true
                    if(border.playerOneDead)
                    {
                        processor.isProcessing = false
                        parent.processorProcessing = false
                        timerPlayerOneLost.restart()
                    }
                }

                function died()
                {
                    if(border.twoPlayerLife && border.twoPlayers)
                    {
                        level = 0;
                        --border.twoPlayerLife
                        waitAnimationTwo.restart()
                    }
                    else
                    {
                        noMoreLife()
                    }
                }

                Timer
                {
                    id: waitAnimationTwo
                    interval: 2000
                    running: false
                    repeat: false
                    onTriggered:
                    {
                        tankPlayerTwo.rotation = 0
                        tankPlayerTwo.x = 4 + 16 * levelField.width / 26
                        tankPlayerTwo.y = 6 + 24 * levelField.height / 26
                        revivePlayerTwo.restart()
                    }
                }

                Timer
                {
                    id: revivePlayerTwo
                    interval: 1000
                    running: false
                    repeat: false
                    onTriggered:
                    {
                        tankPlayerTwo.visible = true
                    }
                }

                SoundEffect {
                    id: tankTwoEngineSound
                    volume: .45
                    source: "qrc:/Audio/tankTwo.wav"
                    loops: SoundEffect.Infinite
                }

            }

            Tank {
                id: tankEnemyOne
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !parent.processorProcessing
                playing: parent.processorProcessing
                visible: false
                rotation: 180
                source: level === 0 && specialPowerUp === false ? "qrc:/Images/playerAI-1.gif" : level === 1 && specialPowerUp === false ? "qrc:/Images/playerAI-2.gif" : level === 0 && specialPowerUp === true ? "qrc:/Images/playerAI-1-special.gif" : level === 1 && specialPowerUp === true ? "qrc:/Images/playerAI-2-special.gif" : "qrc:/Images/playerAI-1.gif"
                type: 2
                player: 3
                x: 4 + 12 * parent.width / 26
                y: 6 + 0 * parent.height / 26

                onPlayingChanged:
                {
                    if(playing)
                        tankEnemyOneEngineSound.play()
                    else
                        tankEnemyOneEngineSound.stop()
                }

                function died()
                {
                    if(myKiller === 1)
                        ++enemiesKilled[level]
                    else if(myKiller === 2)
                        ++enemiesKilledTwo[level]
                    if(specialPowerUp)
                    {
                        specialPowerUp = false
                        powerUp.visible = true
                        specialEnemyExists = false
                    }
                }

                SoundEffect {
                    id: tankEnemyOneEngineSound
                    volume: .45
                    source: "qrc:/Audio/tankEnemy.wav"
                    loops: SoundEffect.Infinite
                }
            }

            Tank {
                id: tankEnemyTwo
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !parent.processorProcessing
                playing: parent.processorProcessing
                visible: false
                rotation: 180
                source: level === 0 && specialPowerUp === false ? "qrc:/Images/playerAI-1.gif" : level === 1 && specialPowerUp === false ? "qrc:/Images/playerAI-2.gif" : level === 0 && specialPowerUp === true ? "qrc:/Images/playerAI-1-special.gif" : level === 1 && specialPowerUp === true ? "qrc:/Images/playerAI-2-special.gif" : "qrc:/Images/playerAI-1.gif"
                type: 2
                player: 4
                x: 4 + 12 * parent.width / 26
                y: 6 + 0 * parent.height / 26

                onPlayingChanged:
                {
                    if(playing)
                        tankEnemyOneEngineSound.play()
                    else
                        tankEnemyOneEngineSound.stop()
                }

                function died()
                {
                    if(myKiller === 1)
                        ++enemiesKilled[level]
                    else if(myKiller === 2)
                        ++enemiesKilledTwo[level]
                    if(specialPowerUp)
                    {
                        specialPowerUp = false
                        powerUp.visible = true
                        specialEnemyExists = false
                    }
                }
            }

            Tank {
                id: tankEnemyThree
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !parent.processorProcessing
                playing: parent.processorProcessing
                visible: false
                rotation: 180
                source: level === 0 && specialPowerUp === false ? "qrc:/Images/playerAI-1.gif" : level === 1 && specialPowerUp === false ? "qrc:/Images/playerAI-2.gif" : level === 0 && specialPowerUp === true ? "qrc:/Images/playerAI-1-special.gif" : level === 1 && specialPowerUp === true ? "qrc:/Images/playerAI-2-special.gif" : "qrc:/Images/playerAI-1.gif"
                type: 2
                player: 5
                x: 4 + 12 * parent.width / 26
                y: 6 + 0 * parent.height / 26

                onPlayingChanged:
                {
                    if(playing)
                        tankEnemyOneEngineSound.play()
                    else
                        tankEnemyOneEngineSound.stop()
                }

                function died()
                {
                    if(myKiller === 1)
                        ++enemiesKilled[level]
                    else if(myKiller === 2)
                        ++enemiesKilledTwo[level]
                    if(specialPowerUp)
                    {
                        specialPowerUp = false
                        powerUp.visible = true
                        specialEnemyExists = false
                    }
                }
            }

            Tank {
                id: tankEnemyFour
                width: 6.5 * levelField.blockWidth //parent.width / 16
                height: 6.5 * levelField.blockHeight //parent.height / 16
                paused: !parent.processorProcessing
                playing: parent.processorProcessing
                visible: false
                rotation: 180
                source: level === 0 && specialPowerUp === false ? "qrc:/Images/playerAI-1.gif" : level === 1 && specialPowerUp === false ? "qrc:/Images/playerAI-2.gif" : level === 0 && specialPowerUp === true ? "qrc:/Images/playerAI-1-special.gif" : level === 1 && specialPowerUp === true ? "qrc:/Images/playerAI-2-special.gif" : "qrc:/Images/playerAI-1.gif"
                type: 2
                player: 6
                x: 4 + 12 * parent.width / 26
                y: 6 + 0 * parent.height / 26

                onPlayingChanged:
                {
                    if(playing)
                        tankEnemyOneEngineSound.play()
                    else
                        tankEnemyOneEngineSound.stop()
                }

                function died()
                {
                    if(myKiller === 1)
                        ++enemiesKilled[level]
                    else if(myKiller === 2)
                        ++enemiesKilledTwo[level]
                    if(specialPowerUp)
                    {
                        specialPowerUp = false
                        powerUp.visible = true
                        specialEnemyExists = false
                    }
                }
            }

            AnimatedImage
            {
                id: powerUp
                width: 9 * levelField.blockWidth
                height: 9 * levelField.blockHeight
                visible: false
                fillMode: Image.Stretch
                source: type === 0 ? "qrc:/Images/starPowerUp.gif" : type === 1 ? "qrc:/Images/lifePowerUp.gif" : "qrc:/Images/lifePowerUp.gif"
                property int type: 0
                property bool isBullet: false
                property bool base: false
                property int player: -2
                property bool solid: false
                property bool breakable: false

                onVisibleChanged:
                {
                    if(!visible)
                        powerUpSound.play()
                }

                SoundEffect {
                    id: powerUpSound
                    volume: .45
                    source: powerUp.type === 1 ? "qrc:/Audio/1-up.wav" : "qrc:/Audio/levelUp.wav"
                }
            }

            Timer
            {
                id: createNewEnemy
                interval: 200
                running: parent.canCreateEnemy && parent.processorProcessing
                repeat: parent.canCreateEnemy && parent.processorProcessing
                onTriggered:
                {
                    interval = 3000
                    if(border.enemiesLife){
                        --border.enemiesLife
                        enemiesLifeModel.remove(0)
                        var nextX = 0
                        if(parent.nextEnemyPosition === 0)
                            nextX = 4 + 12 * parent.width / 26
                        if(parent.nextEnemyPosition === 1)
                            nextX = 4 + 24 * parent.width / 26
                        if(parent.nextEnemyPosition === 2)
                            nextX = 4 + 0 * parent.width / 26

                        ++parent.nextEnemyPosition

                        var levelEnemy = 0;
                        var random = Math.random()
                        if(random < 0.1)
                            levelEnemy = 1;

                        var specialPowerUp = 0
                        random = Math.random()
                        if(!powerUp.visible && !specialEnemyExists)
                            if(random < border.specialEnemyProb)
                            {
                                specialEnemyExists = true
                                specialPowerUp = 1;
                                powerUp.x = 4 + (25 * Math.random()) * parent.width / 26
                                powerUp.y = 4 + (25 * Math.random()) * parent.height / 26
                                if(Math.random() < 0.5)
                                    powerUp.type = 0
                                else
                                    powerUp.type = 1
                            }

                        if(!tankEnemyOne.visible)
                        {
                            tankEnemyOne.specialPowerUp = specialPowerUp
                            tankEnemyOne.y = 6 + 0 * parent.height / 26
                            tankEnemyOne.x = nextX
                            tankEnemyOne.level = levelEnemy
                            tankEnemyOne.revive()
                        }
                        else if(!tankEnemyTwo.visible)
                        {
                            tankEnemyTwo.specialPowerUp = specialPowerUp
                            tankEnemyTwo.y = 6 + 0 * parent.height / 26
                            tankEnemyTwo.x = nextX
                            tankEnemyTwo.level = levelEnemy
                            tankEnemyTwo.revive()
                        }
                        else if(!tankEnemyThree.visible)
                        {
                            tankEnemyThree.specialPowerUp = specialPowerUp
                            tankEnemyThree.y = 6 + 0 * parent.height / 26
                            tankEnemyThree.x = nextX
                            tankEnemyThree.level = levelEnemy
                            tankEnemyThree.revive()
                        }
                        else if(!tankEnemyFour.visible)
                        {
                            tankEnemyFour.specialPowerUp = specialPowerUp
                            tankEnemyFour.y = 6 + 0 * parent.height / 26
                            tankEnemyFour.x = nextX
                            tankEnemyFour.level = levelEnemy
                            tankEnemyFour.revive()
                        }
                    }
                    else
                    {
                        if(!tankEnemyOne.visible && !tankEnemyTwo.visible && !tankEnemyThree.visible && !tankEnemyFour.visible)
                        {
                            pageLoader.setSource("pontuationScreen.qml", {"enemiesKilled":border.enemiesKilled, "enemiesKilledTwo":border.enemiesKilledTwo, "playerOneWon":!border.playerOneDead, "playerTwoWon":!border.playerTwoDead, "twoPlayers":border.twoPlayers})
                            //player one won
                        }
                    }
                }
            }
        }
    }

    Text {
        id: oneLife
        text: "1P"
        anchors.right: parent.right
        anchors.rightMargin: 35
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 50
        font.pixelSize: parent.height / 30
        color: "black"
    }

    Image {
        id: onePlayerLifeImage
        width: parent.width / 40
        height: parent.width / 40
        visible: levelVisible
        source: "qrc:/Images/oneLives.png"
        fillMode: Image.Stretch
        anchors.left: oneLife.left
        anchors.leftMargin: -5
        anchors.top: oneLife.bottom
        anchors.topMargin: 5
    }

    Text {
        id: oneLifeNumber
        text: onePlayerLife.toString()
        anchors.left: onePlayerLifeImage.right
        anchors.leftMargin: 5
        anchors.verticalCenter: onePlayerLifeImage.verticalCenter
        font.pixelSize: parent.height / 30
        color: "black"
    }

    Rectangle {
        id: enemiesLifeRectangle
        height: parent.height / 4
        width: 50
        visible: levelVisible
        color: "transparent"
        anchors {
            right: parent.right
            rightMargin: 23
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -parent.height / 4
        }

        GridView {
            id: enemiesLife
            cellWidth: 22
            cellHeight: 20
            anchors.fill: parent

            model: ListModel {
                id: enemiesLifeModel
            }

            delegate: Component {
                    id: enemiesDelegate
                    Image {
                        source: "qrc:/Images/enemiesLives.png"
                        width: enemiesLife.cellWidth - 2
                        height: enemiesLife.cellHeight
                        //anchors.centerIn: parent
                    }
                }

            Component.onCompleted:
            {
                for (var i = 0; i < border.enemiesLife; ++i)
                {
                    enemiesLifeModel.append({})
                }
            }
        }
    }

    ParallelAnimation {
        id: animation1
        running: false
        SequentialAnimation {
            NumberAnimation { target: grayRectangleTop; property: "y"; to: 0; duration: 300 }
        }
        SequentialAnimation {
            NumberAnimation { target: grayRectangleBottom; property: "y"; to: grayRectangleBottom.height; duration: 300 }
        }
        onStopped:
        {
            levelVisible = true;
        }
    }

    ParallelAnimation {
        id: animation2
        running: false
        SequentialAnimation {
            NumberAnimation { target: grayRectangleTop; property: "y"; to: -grayRectangleTop.height; duration: 300 }
        }
        SequentialAnimation {
            NumberAnimation { target: grayRectangleBottom; property: "y"; to: grayRectangleBottom.height * 2; duration: 300 }
        }
        onStarted:
        {
            stageIdText.visible = false
            processor.forceActiveFocus()
            //levelField.playGameStart()
        }
        onStopped:
        {
            if(!firstAnimationFinished)
            {
                processor.isProcessing = true
                firstAnimationFinished = true
            }
        }
    }

    Rectangle {
        id: grayRectangleTop
        height: window.height / 2
        width: parent.width
        y: -height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#535353"
    }
    Rectangle {
        id: grayRectangleBottom
        height: window.height / 2
        width: parent.width
        y: 2 * height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#535353"
    }

    Text {
        id: stageIdText
        text: "STAGE 1"
        anchors.centerIn: parent
        font.pixelSize: parent.height / 30
        color: "black"
    }

    Rectangle
    {
        id: rectanglePause
        width: .8 * parent.width
        height: .8 * parent.height
        anchors.centerIn: parent
        border.width: 4
        border.color: "black"
        radius: width / 20
        color: "#DD777777"
        visible: !processor.isProcessing && firstAnimationFinished && !timerPlayerOneLost.running

        Text {
            id: pauseText
            text: "PAUSE"
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height / 20
            font.pixelSize: parent.height / 30
            font.bold: true
            color: "red"
        }
        Timer {
            id: timerPaused
            running: !processor.isProcessing && firstAnimationFinished && !timerPlayerOneLost.running
            repeat: !processor.isProcessing && firstAnimationFinished && !timerPlayerOneLost.running
            interval: 300
            onTriggered: pauseText.visible = !pauseText.visible
        }

        Column {
            anchors.top: pauseText.bottom
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
                color: "black"
            }
            Text {
                text: "P1"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Up: Key UP"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Down: Key Down"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Left: Key Left"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Right: Key Right"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Fire: Key 'M'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "P2"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Up: Key 'R'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Down: Key 'F'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Left: Key 'D'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Right: Key 'G'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
            Text {
                text: "Fire: Key 'Z'"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: parent.height / 30
                font.bold: true
                color: "black"
            }
        }
    }

    Text {
        id: pressPText
        text: "Press 'P' to pause and see help"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        font.pixelSize: parent.height / 40
        font.bold: true
        color: "black"
        visible: firstAnimationFinished
    }

    Processor {
        id: processor

        twoPlayers: border.twoPlayers

        onPlayerOneFire:
        {
            if (tankPlayerOne.visible) tankPlayerOne.processFire();
        }

        onPlayerOneSignal:
        {
            tankPlayerOne.processMovement(up, down, left, right)
            tankEnemyOne.processMovement(0, 0, 0, 0)
            tankEnemyTwo.processMovement(0, 0, 0, 0)
            tankEnemyThree.processMovement(0, 0, 0, 0)
            tankEnemyFour.processMovement(0, 0, 0, 0)
        }

        onPlayerTwoSignal:
        {
            tankPlayerTwo.processMovement(up, down, left, right)
        }

        onPlayerTwoFire:
        {
            if (tankPlayerTwo.visible) tankPlayerTwo.processFire();
        }
    }
}

