import QtQuick 2.4
import QtMultimedia 5.4

Image {
    id: bulletRoot
    width: 9
    height: 10

    source: "qrc:/Images/bullet.png"
    visible: false

    property bool solid: false
    property bool isBullet: true

    signal explode()

    property int player: 0
    property int speed: 20

    Behavior on x { PropertyAnimation { easing.type: Easing.Linear; duration: 50 } }
    Behavior on y { PropertyAnimation { easing.type: Easing.Linear; duration: 50 } }

    SoundEffect {
        id: shootSound
        volume: .6
        source: "qrc:/Audio/shoot.wav"
    }

    Component.onCompleted: shootSound.play()

    onExplode:
    {
        parent.playerOneDelBullet(player);
        processor.process.disconnect(processMovement)
    }

    onYChanged:
    {
        if(visible)
        {
            if(y <= 0 || y >= parent.height - height)
                explode()
            else
            {
                var block = null;
                var block2 = null;
                var block3 = null;

                var countY
                var lastY
                var block1Solid = false
                var block2Solid = false
                var block1Enemy = 0
                var block2Enemy = 0
                var block1Bullet = false
                var block2Bullet = false

                if(rotation === 0)
                {
                    block = parent.childAt(x + width / 3, y - height / 3);
                    block2 = parent.childAt(x + 2 * width / 3, y - height / 3);
                    if(block)
                    {
                        block1Solid = block.solid
                        block1Enemy = block.player
                        block1Bullet = block.isBullet
                    }
                    if(block2)
                    {
                        block2Solid = block2.solid
                        block2Enemy = block2.player
                        block2Bullet = block2.isBullet
                    }
                    if(block1Solid || block2Solid)
                    {
                        visible = false
                        countY = 0
                        lastY = y;
                        if(block)
                        {
                            while (block)
                            {
                                lastY = y + countY;
                                block = parent.childAt(x - 1, y + countY);
                                countY += parent.blockHeight
                            }
                            lastY -= parent.blockHeight
                        }
                        else if(block2)
                        {
                            while (block2)
                            {
                                lastY = y + countY;
                                block2 = parent.childAt(x + width + 1, y + countY);
                                countY += parent.blockHeight
                            }
                            lastY -= parent.blockHeight
                        }

                        for(var j = 0; j < 2; ++j)
                        {
                            for(var i = 0; i < 8; ++i)
                            {
                                block = parent.childAt(x + width / 2 - (3.5 * parent.blockWidth - parent.blockWidth * i), lastY - (parent.blockHeight * j));
                                if(block)
                                {
                                    if(block.breakable)
                                    {
                                        if(block.player === -1)
                                            levelField.tilesTypes[block.xMap][block.yMap] = 0
                                        if(block.base === false)
                                            block.destroy();
                                        else
                                        {
                                            block.visible = false
                                        }
                                    }
                                }
                            }
                        }
                        explode()
                    }
                    else
                    {
                        if (block1Bullet || block2Bullet)
                        {
                            block.explode()
                            explode()
                        }
                        if(player <= 2 && player > 0)
                        {
                            if(block1Enemy > 2 || block2Enemy > 2)
                            {
                                block.myKiller = bulletRoot.player
                                block.visible = false;
                                explode()
                            }
                        }
                        else if(player > 2)
                        {
                            if((block1Enemy <= 2 && block1Enemy > 0) || (block2Enemy <= 2 && block2Enemy > 0))
                            {
                                block.visible = false;
                                explode()
                            }
                        }
                    }
                }
                else
                {
                    block1Solid = false
                    block2Solid = false
                    block = parent.childAt(x + width / 3, y + 4 * height / 3);
                    block2 = parent.childAt(x + 2 * width / 3, y + 4 * height / 3);

                    if(block)
                    {
                        block1Solid = block.solid
                        block1Enemy = block.player
                        block1Bullet = block.isBullet
                    }
                    if(block2)
                    {
                        block2Solid = block2.solid
                        block2Enemy = block2.player
                        block2Bullet = block2.isBullet
                    }
                    if(block1Solid || block2Solid)
                    {
                        visible = false
                        countY = 0
                        lastY = y;
                        if(block)
                        {
                            while (block)
                            {
                                lastY = y + height + 1 + countY;
                                block = parent.childAt(x - 1, y + height + 1 + countY);
                                countY -= parent.blockHeight
                            }
                            lastY += parent.blockHeight
                        }
                        else if(block2)
                        {
                            while (block2)
                            {
                                lastY = y + height + 1 + countY;
                                block2 = parent.childAt(x + width + 1, y + height + 1 + countY);
                                countY -= parent.blockHeight
                            }
                            lastY += parent.blockHeight
                        }

                        for(var j = 0; j < 2; ++j)
                        {
                            for(var i = 0; i < 8; ++i)
                            {
                                block = parent.childAt(x + width / 2 - (3.5 * parent.blockWidth - parent.blockWidth * i), lastY + (parent.blockHeight * j));
                                if(block)
                                {
                                    if(block.breakable)
                                    {
                                        if(block.player === -1)
                                            levelField.tilesTypes[block.xMap][block.yMap] = 0
                                        if(block.base === false)
                                            block.destroy();
                                        else
                                        {
                                            block.visible = false
                                        }
                                    }
                                }
                            }
                        }
                        explode()
                    }
                    else
                    {
                        if (block1Bullet || block2Bullet)
                        {
                            block.explode()
                            explode()
                        }
                        if(player <= 2 && player > 0)
                        {
                            if(block1Enemy > 2 || block2Enemy > 2)
                            {
                                block.myKiller = bulletRoot.player
                                block.visible = false;
                                explode()
                            }
                        }
                        else if(player > 2)
                        {
                            if((block1Enemy <= 2 && block1Enemy > 0) || (block2Enemy <= 2 && block2Enemy > 0))
                            {
                                block.visible = false;
                                explode()
                            }
                        }
                    }
                }
            }
        }
    }

    onXChanged:
    {
        if(visible)
        {
            if(x <= 0 || x >= parent.width - width)
                explode()
            else
            {
                var block = null;
                var block2 = null;
                var block3 = null;

                var countX
                var lastX
                var block1Solid = false
                var block2Solid = false
                var block1Enemy = 0
                var block2Enemy = 0
                var block1Bullet = false
                var block2Bullet = false

                if(rotation === 270)
                {
                    block = parent.childAt(x - width / 3, y + height / 3);
                    block2 = parent.childAt(x - width / 3, y + 2 * height / 3);
                    if(block)
                    {
                        block1Solid = block.solid
                        block1Enemy = block.player
                        block1Bullet = block.isBullet
                    }
                    if(block2)
                    {
                        block2Solid = block2.solid
                        block2Enemy = block2.player
                        block2Bullet = block2.isBullet
                    }
                    if(block1Solid || block2Solid)
                    {
                        visible = false
                        countX = 0
                        lastX = x;
                        if(block)
                        {
                            while (block)
                            {
                                lastX = x + countX;
                                block = parent.childAt(x + countX, y - 1);
                                countX += parent.blockWidth
                            }
                            lastX -= parent.blockWidth
                        }
                        else if(block2)
                        {
                            while (block2)
                            {
                                lastX = x + countX;
                                block2 = parent.childAt(x + countX, y + height + 1);
                                countX += parent.blockWidth
                            }
                            lastX -= parent.blockWidth
                        }

                        for(var j = 0; j < 2; ++j)
                        {
                            for(var i = 0; i < 8; ++i)
                            {
                                block = parent.childAt(lastX - (parent.blockWidth * j), y + height / 2 - (3.5 * parent.blockHeight - parent.blockHeight * i));
                                if(block)
                                {
                                    if(block.breakable)
                                    {
                                        if(block.player === -1)
                                            levelField.tilesTypes[block.xMap][block.yMap] = 0
                                        if(block.base === false)
                                            block.destroy();
                                        else
                                        {
                                            block.visible = false
                                        }
                                    }
                                }
                            }
                        }
                        explode()
                    }
                    else
                    {
                        if (block1Bullet || block2Bullet)
                        {
                            block.explode()
                            explode()
                        }
                        if(player <= 2 && player > 0)
                        {
                            if(block1Enemy > 2 || block2Enemy > 2)
                            {
                                block.myKiller = bulletRoot.player
                                block.visible = false;
                                explode()
                            }
                        }
                        else if(player > 2)
                        {
                            if((block1Enemy <= 2 && block1Enemy > 0) || (block2Enemy <= 2 && block2Enemy > 0))
                            {
                                block.visible = false;
                                explode()
                            }
                        }
                    }
                }
                else
                {
                    block1Solid = false
                    block2Solid = false
                    block = parent.childAt(x + 4 * width / 3, y + height / 3);
                    block2 = parent.childAt(x + 4 * width / 3, y + 2 * height / 3);

                    if(block)
                    {
                        block1Solid = block.solid
                        block1Enemy = block.player
                        block1Bullet = block.isBullet
                    }
                    if(block2)
                    {
                        block2Solid = block2.solid
                        block2Enemy = block2.player
                        block2Bullet = block2.isBullet
                    }
                    if(block1Solid || block2Solid)
                    {
                        visible = false
                        countX = 0
                        lastX = x;
                        if(block)
                        {
                            while (block)
                            {
                                lastX = x + width + 1 + countX;
                                block = parent.childAt(x + width + 1 + countX, y - 1);
                                countX -= parent.blockWidth
                            }
                            lastX += parent.blockWidth
                        }
                        else if(block2)
                        {
                            while (block2)
                            {
                                lastX = x + width + 1 + countX;
                                block2 = parent.childAt(x + width + 1 + countX, y + height + 1);
                                countX -= parent.blockWidth
                            }
                            lastX += parent.blockWidth
                        }

                        for(var j = 0; j < 2; ++j)
                        {
                            for(var i = 0; i < 8; ++i)
                            {
                                block = parent.childAt(lastX + (parent.blockWidth * j), y + height / 2 - (3.5 * parent.blockHeight - parent.blockHeight * i));
                                if(block)
                                {
                                    if(block.breakable)
                                    {
                                        if(block.player === -1)
                                            levelField.tilesTypes[block.xMap][block.yMap] = 0
                                        if(block.base === false)
                                            block.destroy();
                                        else
                                        {
                                            block.visible = false
                                        }
                                    }
                                }
                            }
                        }
                        explode()
                    }
                    else
                    {
                        if (block1Bullet || block2Bullet)
                        {
                            block.explode()
                            explode()
                        }
                        if(player <= 2 && player > 0)
                        {
                            if(block1Enemy > 2 || block2Enemy > 2)
                            {
                                block.myKiller = bulletRoot.player
                                block.visible = false;
                                explode()
                            }
                        }
                        else if(player > 2)
                        {
                            if((block1Enemy <= 2 && block1Enemy > 0) || (block2Enemy <= 2 && block2Enemy > 0))
                            {
                                block.visible = false;
                                explode()
                            }
                        }
                    }
                }
            }
        }
    }

    function processMovement()
    {
        if(visible)
        {
            var block = null;
            var block2 = null;
            if(rotation === 0)
                y -= speed
            else if(rotation === 90)
                x += speed
            else if(rotation === 180)
                y += speed
            else if(rotation === 270)
                x -= speed
        }
    }

    function startAnimation()
    {
        startAnimationTimer.restart()
    }

    Timer {
        id: startAnimationTimer
        running: false
        repeat: false
        interval: 50
        onTriggered: visible = true
    }
}

