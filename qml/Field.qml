import QtQuick 2.4
import QtQuick.Controls 1.3
import QtMultimedia 5.4
import "./"

Rectangle {
    id: rootField
    width: parent.width
    height: parent.height
    color: "black"

    signal eraseTiles()
    signal drawingFinished()

    property var tilesTypes: [[]]
    property real blockWidth: width / tilesTypes[0].length
    property real blockHeight: height / tilesTypes.length
    property int player: -1
    property int nextEnemyPosition: 0

    onTilesTypesChanged:
    {
        //console.log(tilesTypes.length)
    }

    onNextEnemyPositionChanged:
    {
        if(nextEnemyPosition > 2)
            nextEnemyPosition = 0;
    }

    /*function playGameStart() { player.play() }
    MediaPlayer {
        id: player
        autoLoad: true
        autoPlay: false
        source: "qrc:/Audio/gameStart.mp3"
    }*/

    Timer {
        id: drawTimer
        running: false
        repeat: false
        interval: 1
        onTriggered: {
            drawTiles()
        }
    }

    function startTimer()
    {
        drawTimer.restart()
    }

    function drawTiles()
    {
        var imageWidth = rootField.width / tilesTypes[0].length
        var imageHeight = rootField.height / tilesTypes.length

        for(var i = 0; i < tilesTypes.length; ++i)
            for(var j = 0; j < tilesTypes[i].length; ++j)
            {
                var brickNumber;
                var isSolid;
                var isBreakable;

                if(tilesTypes[i][j] === 1)
                {
                    isSolid = true
                    isBreakable = true
                    if(i%4 === 0)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 1;
                                break;
                            case 1:
                                brickNumber = 2;
                                break;
                            case 2:
                                brickNumber = 3;
                                break;
                            case 3:
                                brickNumber = 4;
                                break;
                        }
                    else if (i%4 === 1)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 5;
                                break;
                            case 1:
                                brickNumber = 6;
                                break;
                            case 2:
                                brickNumber = 7;
                                break;
                            case 3:
                                brickNumber = 8;
                                break;
                        }
                    else if (i%4 === 2)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 3;
                                break;
                            case 1:
                                brickNumber = 4;
                                break;
                            case 2:
                                brickNumber = 1;
                                break;
                            case 3:
                                brickNumber = 2;
                                break;
                        }
                    else if (i%4 === 3)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 7;
                                break;
                            case 1:
                                brickNumber = 8;
                                break;
                            case 2:
                                brickNumber = 5;
                                break;
                            case 3:
                                brickNumber = 6;
                                break;
                        }
                    var tile = Qt.createQmlObject('import QtQuick 2.4; import QtLocation 5.0; Image{property bool base: false; property int xMap: ' + i + '; property int yMap: ' + j + '; property bool isBullet: false; property int player: -1; property bool isExplosion: false; property bool solid: ' + isSolid + '; property bool breakable: ' + isBreakable + '; width: ' + imageWidth + '; height: ' + imageHeight + '; x: ' + j + ' * ' + imageWidth + '; y: ' + i + ' * ' + imageHeight + '; fillMode: Image.Stretch; source: "qrc:/Images/brick' + brickNumber + '.png";}', rootField);
                    rootField.eraseTiles.connect(tile.destroy);
                }
                else if(tilesTypes[i][j] === 2)
                {
                    isSolid = true
                    isBreakable = false
                    if(i%4 === 0)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 1;
                                break;
                            case 1:
                                brickNumber = 2;
                                break;
                            case 2:
                                brickNumber = 3;
                                break;
                            case 3:
                                brickNumber = 4;
                                break;
                        }
                    else if(i%4 === 1)
                            switch (j%4)
                            {
                                case 0:
                                    brickNumber = 5;
                                    break;
                                case 1:
                                    brickNumber = 6;
                                    break;
                                case 2:
                                    brickNumber = 7;
                                    break;
                                case 3:
                                    brickNumber = 8;
                                    break;
                            }
                    else if(i%4 === 2)
                        switch (j%4)
                        {
                            case 0:
                                brickNumber = 9;
                                break;
                            case 1:
                                brickNumber = 10;
                                break;
                            case 2:
                                brickNumber = 11;
                                break;
                            case 3:
                                brickNumber = 12;
                                break;
                        }
                    else if(i%4 === 3)
                            switch (j%4)
                            {
                                case 0:
                                    brickNumber = 13;
                                    break;
                                case 1:
                                    brickNumber = 14;
                                    break;
                                case 2:
                                    brickNumber = 15;
                                    break;
                                case 3:
                                    brickNumber = 16;
                                    break;
                            }
                    var tile = Qt.createQmlObject('import QtQuick 2.4; import QtLocation 5.0; Image{ property bool base: false; property int xMap: ' + i + '; property int yMap: ' + j + '; z: 1; property bool isBullet: false; property int player: -1; property bool solid: ' + isSolid + '; property bool breakable: ' + isBreakable + '; width: ' + imageWidth + '; height: ' + imageHeight + '; x: ' + j + ' * ' + imageWidth + '; y: ' + i + ' * ' + imageHeight + '; fillMode: Image.Stretch; source: "qrc:/Images/solid' + brickNumber + '.png" }', rootField);
                    rootField.eraseTiles.connect(tile.destroy);
                }

            }
        parent.visible = true;
    }
}

