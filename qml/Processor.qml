import QtQuick 2.4

Item
{
    anchors.fill: parent
    focus: true

    signal process()

    signal playerOneSignal(bool up, bool down, bool left, bool right)
    signal playerOneFire()

    signal playerTwoSignal(bool up, bool down, bool left, bool right)
    signal playerTwoFire()

    property bool upPressed: false
    property bool downPressed: false
    property bool leftPressed: false
    property bool rightPressed: false
    property bool playerOneFirePressed: false
    property bool moving: false

    property bool upTwoPressed: false
    property bool downTwoPressed: false
    property bool leftTwoPressed: false
    property bool rightTwoPressed: false
    property bool playerTwoFirePressed: false
    property bool movingTwo: false

    property bool isProcessing: false
    property bool twoPlayers: false

    onIsProcessingChanged: {
        if(!isProcessing) timerProcessing.stop;
    }

    Keys.onPressed: {
        if(!event.isAutoRepeat)
        {
            if(event.key === Qt.Key_Down)
            {
                downPressed = true
            }
            else if(event.key === Qt.Key_Up)
            {
                upPressed = true
            }
            else if(event.key === Qt.Key_Left)
            {
                leftPressed = true
            }
            else if(event.key === Qt.Key_Right)
            {
                rightPressed = true
            }
            if (event.key === Qt.Key_M)
            {
                if(!fireInterval.running)
                    playerOneFirePressed = true
            }

            if(twoPlayers)
            {
                if(event.key === Qt.Key_F)
                {
                    downTwoPressed = true
                }
                else if(event.key === Qt.Key_R)
                {
                    upTwoPressed = true
                }
                else if(event.key === Qt.Key_D)
                {
                    leftTwoPressed = true
                }
                else if(event.key === Qt.Key_G)
                {
                    rightTwoPressed = true
                }
                if (event.key === Qt.Key_Z)
                {
                    if(!fireInterval.running)
                        playerTwoFirePressed = true
                }
            }
        }
    }
    Keys.onReleased: {
        if(!event.isAutoRepeat)
        {
            if(event.key === Qt.Key_Down)
                downPressed = false
            else if(event.key === Qt.Key_Up)
                upPressed = false
            else if(event.key === Qt.Key_Left)
                leftPressed = false
            else if(event.key === Qt.Key_Right)
                rightPressed = false
            if(event.key === Qt.Key_M)
                playerOneFirePressed = false

            if(twoPlayers)
            {
                if(event.key === Qt.Key_F)
                    downTwoPressed = false
                else if(event.key === Qt.Key_R)
                    upTwoPressed = false
                else if(event.key === Qt.Key_D)
                    leftTwoPressed = false
                else if(event.key === Qt.Key_G)
                    rightTwoPressed = false
                if(event.key === Qt.Key_Z)
                    playerTwoFirePressed = false
            }
        }
    }

    Timer
    {
        id: timerProcessing
        running: isProcessing
        repeat: isProcessing
        interval: 50

        onTriggered:
        {
            process();

            if(!(upPressed || downPressed || leftPressed || rightPressed))
                moving = false
            else
                moving = true

            playerOneSignal(upPressed, downPressed, leftPressed, rightPressed)

            if(playerOneFirePressed && !fireInterval.running)
            {
                fireInterval.restart()
                playerOneFire();
            }

            if(twoPlayers)
            {
                if(!(upTwoPressed || downTwoPressed || leftTwoPressed || rightTwoPressed))
                    movingTwo = false
                else
                    movingTwo = true

                playerTwoSignal(upTwoPressed, downTwoPressed, leftTwoPressed, rightTwoPressed)

                if(playerTwoFirePressed && !fireIntervalTwo.running)
                {
                    fireIntervalTwo.restart()
                    playerTwoFire();
                }
            }
        }
    }

    Timer
    {
        id: fireInterval
        running: false
        repeat: false
        interval: 100
        onTriggered: playerOneFirePressed = false
    }
    Timer
    {
        id: fireIntervalTwo
        running: false
        repeat: false
        interval: 100
        onTriggered: playerTwoFirePressed = false
    }
}

