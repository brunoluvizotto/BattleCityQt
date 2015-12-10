import QtQuick 2.4

Image {
    height: 8 * parent.height / parent.tilesTypes.length
    width: 8 * parent.width / parent.tilesTypes.length

    source: "qrc:/Images/basePlayerOne.png"
    visible: true

    property int player: 0
    property bool solid: true
    property bool isBullet: false
    property bool breakable: true
    property bool base: true

}
