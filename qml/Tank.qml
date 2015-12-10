import QtQuick 2.4

AnimatedImage
{
    id: tankRoot
    height: 28
    width: 32
    fillMode: Image.Stretch
    source: level === 0 ? "qrc:/Images/playerOne.gif" : level === 1 ? "qrc:/Images/playerOneL2.gif" : "qrc:/Images/playerOneL2.gif"

    property int type: 0
    property int level: 0
    property int player: 0
    property int maxBullets: level === 0 || level === 1 ? 1 : level === 2 ? 2 : 1
    property int simultaneousBullets: 0
    property int speedBullet: level === 0 ? 13 : 16
    property int speed: level === 0 ? 5 : level === 1 ? 9 : level === 2 ? 9 : 5
    property real oldX: 0
    property real oldY: 0
    property int myKiller: 0
    property bool specialPowerUp: false

    property bool aiCanChangeDirection: false

    property int xMap: Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1
    property int yMap: Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1

    property bool isBullet: false

    property int aiDirection: 2
    onAiDirectionChanged: aiCanChangeDirection = false

    function died()
    {

    }

    onVisibleChanged:
    {
        if(!visible)
        {
            if(parent)
            {
                if(type !== -1 && tankRoot.parent.processorProcessing)
                {
                    died()
                    var tankExplosion = Qt.createComponent("TankExplosion.qml");
                    var object2 = tankExplosion.createObject(parent);
                    object2.finishedAnimation.connect(object2.destroy)
                    object2.anchors.centerIn = tankRoot
                    object2.width = tankRoot.width * 2
                    object2.height = tankRoot.height * 2.4
                    object2.startAnimation()

                    //console.log(parent)
                    if(parent)
                        parent.activateEnemyTimer()
                }
            }
        }
        else if (player > 2)
            playing = true
    }

    onYChanged:
    {
    }

    Behavior on x { PropertyAnimation { easing.type: Easing.Linear; duration: 50 } }
    Behavior on y { PropertyAnimation { easing.type: Easing.Linear; duration: 50 } }

    function revive()
    {
        reviveTimer.restart()
    }

    Timer {
        id: reviveTimer
        running: false
        repeat: false
        interval: 200
        onTriggered:
        {
            visible = true
        }
    }

    function changeAiDirection()
    {
        var newDirection = aiDirection;

        var rightProb =  .35 * (1 - ((x + (width / 2)) / parent.width))
        /*console.log("rightProb: " + rightProb)
        console.log("x + (width / 2): " + (x + (width / 2)) + " | parent.width: " + parent.width)*/
        var random = 0

        while(newDirection === aiDirection)
        {
            random = Math.random()
            if(random < rightProb)
                newDirection = 1
            else if(random >= rightProb && random < 0.35)
                newDirection = 3
            else if(random >= 0.35 && random < 0.9)
                newDirection = 2
            else if(random >= 0.9)
                newDirection = 0
        }
        //console.log("NewDirection: " + newDirection)
        aiDirection = newDirection
    }

    Timer {
        id: aiShoot
        running: (player > 2) && visible && levelField.processorProcessing
        repeat: tankRoot.parent.processorProcessing
        interval: 3000
        onTriggered:
        {
            if(!aiShootingNotAllowedTimer.running)
            {
                processFire()
                interval = 1000 + 2000 * Math.random()
                restart()
            }
            else
            {
                interval = 100
                restart()
            }
        }
    }

    Timer {
        id: aiShootingNotAllowedTimer
        running: false
        repeat: false
        interval: 50
        onTriggered:
        {
            stop()
        }
    }

    function createBullet(speed, angle)
    {
        var bullet = Qt.createComponent("Bullet.qml");
        var object = bullet.createObject(levelField);
        object.player = player
        if(angle === 0)
        {
            object.x = x + width / 2 - object.width / 2
            object.y = y - object.height
        }
        else if(angle === 180)
        {
            object.x = x + width / 2 - object.width / 2
            object.y = y + height
        }
        else if(angle === 90)
        {
            object.x = x + width
            object.y = y + height / 2 - object.height / 2
        }
        else if(angle === 270)
        {
            object.x = x - object.width
            object.y = y + height / 2 - object.height / 2
        }

        var bulletExplosion = Qt.createComponent("BulletExplosion.qml");
        var object2 = bulletExplosion.createObject(levelField);
        object.rotation = angle;
        object.speed = speed;
        object.startAnimation();
        object.explode.connect(object2.startAnimation)
        object.explode.connect(object.destroy)
        processor.process.connect(object.processMovement)
        object2.finishedAnimation.connect(object2.destroy)
        object2.anchors.centerIn = object
        object2.width = levelField.blockWidth * 8
        object2.height = object2.width * 0.9
    }

    function processFire()
    {
        if(simultaneousBullets < maxBullets)
        {
            ++simultaneousBullets;
            createBullet(speedBullet, rotation)
        }
    }

    Timer {
        id: aiCanChangeDirectionTimer
        running: parent.playing
        repeat: parent.playing
        interval: 3000
        onTriggered: aiCanChangeDirection = true
    }

    function processMovement(up, down, left, right)
    {
        if((player === 1 || player === 2) && visible)
        {

            var block = null;
            var block2 = null;
            var block3 = null;
            var block4 = null;
            var lastY = null;
            var countY = null;

            if(up)
            {
                if(rotation === 270)
                {
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos >= 5 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos - 5] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos - 5] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else if(rotation === 90)
                {
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos < 92 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos + 12] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos + 12] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else
                    x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)

                rotation = 0
                freeWay = 1;
                if(yMap > 0 && xMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap - j * 1][xMap + i] === 1 || levelField.tilesTypes[yMap - j * 1][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + 4, y - levelField.blockHeight);
                    var block2 = parent.childAt(x + width - 5, y - levelField.blockHeight);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(y - speed > 4)
                            y -= speed
                        else
                            y = 4;
                        if(block1Player === -2)
                        {
                            if(!block1.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block1.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block1.visible = false
                        }
                        if(block2Player === -2)
                        {
                            if(!block2.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block2.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block2.visible = false
                        }
                    }
                }
            }
            else if(down)
            {
                if(rotation === 270)
                {
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos >= 5 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos - 5] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos - 5] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else if(rotation === 90)
                {
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos < 92 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos + 12] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos + 12] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else
                    x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)

                rotation = 180
                freeWay = 1;
                if(yMap < 95 && xMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] === 1 || levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + 4, y + height - 1 + levelField.blockHeight);
                    var block2 = parent.childAt(x + width - 5, y + height - 1 + levelField.blockHeight);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0 )
                    {
                        if(y + speed < levelField.height - height - 4)
                            y += speed
                        else
                            y = levelField.height - height - 4;
                        if(block1Player === -2)
                        {
                            if(!block1.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block1.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block1.visible = false
                        }
                        if(block2Player === -2)
                        {
                            if(!block2.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block2.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block2.visible = false
                        }
                    }
                }
            }
            else if(left)
            {
                if(rotation === 180)
                {
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos < 92 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos + 12][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos + 12][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - .5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - 1.5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else if(rotation === 0)
                {
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos >= 5 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos - 5][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos - 5][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - levelField.blockHeight) / (4 * levelField.blockHeight))) + 4)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 4)
                }
                else
                    y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 4)

                rotation = 270
                freeWay = 1;
                if(xMap > 1 && yMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] === 1 || levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x - levelField.blockWidth, y + 4);
                    var block2 = parent.childAt(x - levelField.blockWidth, y + height - 5);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(x - speed > 4)
                            x -= speed
                        else
                            x = 4
                        if(block1Player === -2)
                        {
                            if(!block1.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block1.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block1.visible = false
                        }
                        if(block2Player === -2)
                        {
                            if(!block2.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block2.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block2.visible = false
                        }
                    }
                }
            }
            else if(right)
            {
                if(rotation === 180)
                {
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos < 92 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos + 12][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos + 12][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - .5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - 1.5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else if(rotation === 0)
                {
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos >= 5 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos - 5][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos - 5][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 7)
                }
                else
                    y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 4)

                rotation = 90
                freeWay = 1;
                if(xMap < 95 && yMap < 97)
                for(var i = 0; i < 8; ++i)
                {
                    for(var j = 0; j < 2; ++j)
                    {
                        if(levelField.tilesTypes[yMap + i][xMap + 8 + j * 1] === 1 || levelField.tilesTypes[yMap + i][xMap + 8 + 1 * 2] === 2)
                            freeWay = 0
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + width - 1 + levelField.blockWidth, y + 4);
                    var block2 = parent.childAt(x + width - 1 + levelField.blockWidth, y + height - 5);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(x + speed < levelField.width - width - 4)
                            x += speed
                        else
                            x = levelField.width - width - 4
                        if(block1Player === -2)
                        {
                            if(!block1.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block1.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block1.visible = false
                        }
                        if(block2Player === -2)
                        {
                            if(!block2.type)
                                if(tankRoot.level < 2)
                                    ++tankRoot.level
                            if(block2.type === 1)
                            {
                                if(player === 1)
                                    ++border.onePlayerLife
                                else if (player === 2)
                                    ++border.twoPlayerLife
                            }
                            block2.visible = false
                        }
                    }
                }
            }
        }

        if(player > 2 && visible)
        {
            if(aiCanChangeDirection)
            {
                //aiCanChangeDirection = false
                var freeWayUp = 0
                var freeWayDown = 0
                var freeWayLeft = 0
                var freeWayRight = 0

                if(yMap > 0 && xMap < 97)
                {
                    var sum = 0;
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap - j * 1][xMap + i] !== 1 && levelField.tilesTypes[yMap - j * 1][xMap + i] !== 2)
                                ++sum
                        }
                    }
                    if(sum === 16)
                        freeWayUp = 1
                }
                if(xMap < 95 && yMap < 97)
                {
                    var sum = 0
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + i][xMap + 8 + j * 1] !== 1 && levelField.tilesTypes[yMap + i][xMap + 8 + 1 * 2] !== 2)
                                ++sum
                        }
                    }
                    if(sum === 16)
                        freeWayRight = 1
                }
                if(yMap < 95 && xMap < 97)
                {
                    var sum = 0
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] !== 1 && levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] !== 2)
                                ++sum
                        }
                    }
                    if(sum === 16)
                        freeWayDown = 1
                }
                if(xMap > 1 && yMap < 97)
                {
                    var sum = 0
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] !== 1 && levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] !== 2)
                                ++sum
                        }
                    }
                    if(sum === 16)
                        freeWayLeft = 1
                }

                var rightPos =  (x + (width / 2)) / parent.width
                var downProb = 0.9
                var chance = 0.5;
                if(rotation === 0)
                {
                    if(freeWayRight && freeWayLeft)
                    {
                        var random = Math.random()
                        if (random < (1 - rightPos) * chance)
                            aiDirection = 1;
                        else if (random >= (1 - rightPos) * chance && random < chance)
                            aiDirection = 3;
                    }
                    else if(freeWayRight)
                    {
                        var random = Math.random()
                        if (random < (1 - rightPos) * chance)
                            aiDirection = 1;
                    }
                    else if(freeWayLeft)
                    {
                        var random = Math.random()
                        if (random >= (1 - rightPos) * chance && random < chance)
                            aiDirection = 3;
                    }
                }
                if(rotation === 90)
                {
                    if(freeWayUp && freeWayDown)
                    {
                        var random = Math.random()
                        if (random < downProb * chance)
                            aiDirection = 2;
                        else if (random >= downProb * chance && random < chance)
                            aiDirection = 0;
                    }
                    else if(freeWayUp)
                    {
                        var random = Math.random()
                        if (random < 0.2 * chance)
                            aiDirection = 0;
                    }
                    else if(freeWayDown)
                    {
                        var random = Math.random()
                        if (random < downProb)
                            aiDirection = 2;
                    }
                }
                if(rotation === 180)
                {
                    if(freeWayRight && freeWayLeft)
                    {
                        var random = Math.random()
                        if (random < (1 - rightPos) * chance)
                            aiDirection = 1;
                        else if (random >= (1 - rightPos) * chance && random < chance)
                            aiDirection = 3;
                    }
                    else if(freeWayRight)
                    {
                        var random = Math.random()
                        if (random < (1 - rightPos) * chance)
                            aiDirection = 1;
                    }
                    else if(freeWayLeft)
                    {
                        var random = Math.random()
                        if (random >= (1 - rightPos) * chance && random < chance)
                            aiDirection = 3;
                    }
                }
                if(rotation === 270)
                {
                    if(freeWayUp && freeWayDown)
                    {
                        var random = Math.random()
                        if (random < downProb * chance)
                            aiDirection = 2;
                        else if (random >= downProb * chance && random < chance)
                            aiDirection = 0;
                    }
                    else if(freeWayUp)
                    {
                        var random = Math.random()
                        if (random < 0.2 * chance)
                            aiDirection = 0;
                    }
                    else if(freeWayDown)
                    {
                        var random = Math.random()
                        if (random < downProb)
                            aiDirection = 2;
                    }
                }
            }


            if(oldX === x && oldY === y)
            {
                changeAiDirection()
            }
            oldX = x
            oldY = y

            if(aiDirection === 0)
            {
                if(rotation === 270)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos >= 6 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos - 6] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos - 6] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else if(rotation === 90)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos < 91 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos + 13] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos + 13] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else
                    x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)

                rotation = 0
                freeWay = 1;
                if(yMap > 0 && xMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap - j * 1][xMap + i] === 1 || levelField.tilesTypes[yMap - j * 1][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + 4, y - levelField.blockHeight);
                    var block2 = parent.childAt(x + width - 5, y - levelField.blockHeight);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(y - speed > 4)
                            y -= speed
                        else
                            y = 4;
                    }
                }
            }
            else if(aiDirection === 1)
            {
                if(rotation === 180)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos < 91 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos + 13][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos + 13][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - .5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - 1.5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else if(rotation === 0)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos >= 6 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos - 6][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos - 6][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else
                    y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 7)

                rotation = 90
                freeWay = 1;
                if(xMap < 95 && yMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + i][xMap + 8 + j * 1] === 1 || levelField.tilesTypes[yMap + i][xMap + 8 + 1 * 2] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + width - 1 + levelField.blockWidth, y + 4);
                    var block2 = parent.childAt(x + width - 1 + levelField.blockWidth, y + height - 5);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(x + speed < levelField.width - width - 4)
                            x += speed
                        else
                            x = levelField.width - width - 4
                    }
                }
            }

            else if(aiDirection === 2)
            {
                if(rotation === 270)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos >= 6 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos - 6] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos - 6] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else if(rotation === 90)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryXMapPos = (Math.round(4 * levelField.blockWidth * Math.round((Math.round(levelField.tilesTypes.length * x / (levelField.width)) - 1) / (4 * levelField.blockWidth))) + 4)
                    var freeWay = 1;
                    if(tryXMapPos < 91 && yMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[yMap + i][tryXMapPos + 13] === 1 || levelField.tilesTypes[yMap + i][tryXMapPos + 13] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        x = (Math.round(4 * levelField.blockWidth * Math.round((x - levelField.blockWidth) / (4 * levelField.blockWidth))) + 5)
                    else
                        x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)
                }
                else
                    x = (Math.round(4 * levelField.blockWidth * Math.round(x / (4 * levelField.blockWidth))) + 5)

                rotation = 180
                freeWay = 1;
                if(yMap < 95 && xMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] === 1 || levelField.tilesTypes[yMap + 8 + j * 1][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x + 4, y + height - 1 + levelField.blockHeight);
                    var block2 = parent.childAt(x + width - 5, y + height - 1 + levelField.blockHeight);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(y + speed < levelField.height - height - 4)
                            y += speed
                        else
                            y = levelField.height - height - 4;
                    }
                }
            }
            else if(aiDirection === 3)
            {
                if(rotation === 180)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos < 91 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos + 13][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos + 13][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - .5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - 1.5 * levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else if(rotation === 0)
                {
                    aiShootingNotAllowedTimer.restart()
                    var tryYMapPos = (Math.round(4 * levelField.blockHeight * Math.round((Math.round(levelField.tilesTypes.length * y / (levelField.height)) - 1) / (4 * levelField.blockHeight))) + 4)
                    var freeWay = 1;
                    if(tryYMapPos >= 6 && xMap < 97)
                    {
                        for(var i = 0; i < 8; ++i)
                        {
                            if(levelField.tilesTypes[tryYMapPos - 6][xMap + i] === 1 || levelField.tilesTypes[tryYMapPos - 6][xMap + i] === 2)
                                freeWay = 0
                        }
                    }
                    if(freeWay)
                        y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 7)
                    else
                        y = (Math.round(4 * levelField.blockHeight * Math.round((y - levelField.blockHeight) / (4 * levelField.blockHeight))) + 7)
                }
                else
                    y = (Math.round(4 * levelField.blockHeight * Math.round(y / (4 * levelField.blockHeight))) + 7)

                rotation = 270
                freeWay = 1;
                if(xMap > 1 && yMap < 97)
                {
                    for(var i = 0; i < 8; ++i)
                    {
                        for(var j = 0; j < 2; ++j)
                        {
                            if(levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] === 1 || levelField.tilesTypes[yMap + i][xMap - 1 - j * 1] === 2)
                                freeWay = 0
                        }
                    }
                }
                if(freeWay)
                {
                    var block1 = parent.childAt(x - levelField.blockWidth, y + 4);
                    var block2 = parent.childAt(x - levelField.blockWidth, y + height - 5);
                    var block1Player = -1;
                    var block2Player = -1;
                    if(block1)
                        block1Player = block1.player
                    if(block2)
                        block2Player = block2.player
                    if(block1Player < 0 && block2Player < 0)
                    {
                        if(x - speed > 4)
                            x -= speed
                        else
                            x = 4
                    }
                }
            }
        }
    }
}
