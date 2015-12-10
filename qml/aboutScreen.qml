import QtQuick 2.4

Rectangle
{
    id: rectanglePause
    height: window.height
    width: height
    anchors.centerIn: parent
    border.width: 4
    border.color: "black"
    color: "black"
    visible: true
    focus: true
    property bool isGame: false
    property bool processorProcessing: false

    Keys.onPressed: {
        if(event.key === Qt.Key_Down)
            if(tankSelector.state < 2)
                ++tankSelector.state;
            else
                tankSelector.state = 0;
        else if(event.key === Qt.Key_Up)
            if(tankSelector.state > 0)
                --tankSelector.state;
            else
                tankSelector.state = 2;
        else if(event.key === Qt.Key_Return)
        {
            if(!tankSelector.state)
                Qt.openUrlExternally("mailto:brunoluvizotto@gmail.com?subject=BattleCity game and other things :)")
            else if(tankSelector.state === 1)
                Qt.openUrlExternally("http://br.linkedin.com/pub/bruno-valdrighi-luvizotto/27/8ba/4a6/")
            else if(tankSelector.state === 2)
                pageLoader.setSource("mainScreen.qml")
        }
    }

    Image {
        id: foto
        visible: true
        anchors.centerIn: parent
        height: parent.height / 1.5
        width: parent.width / 1.5
        source: "qrc:/Images/perfil.jpg"
        fillMode: Image.PreserveAspectFit
        opacity: 0.2
    }

    Tank
    {
        id: tankSelector
        property int state: 0

        type: -1
        rotation: 90
        anchors.right: state === 0 ? emailText.left : state === 1 ? linkedInText.left : state === 2 ? pressAnyKeyText.left : pressAnyKeyText.left
        anchors.rightMargin: parent.width / 30
        anchors.verticalCenter: state === 0 ? emailText.verticalCenter : state === 1 ? linkedInText.verticalCenter : state === 2 ? pressAnyKeyText.verticalCenter : pressAnyKeyText.verticalCenter

        xMap: 0
        yMap: 0
    }

    Text {
        id: about
        text: "About"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height / 20
        font.pixelSize: parent.height / 20
        font.bold: true
        color: "darkblue"
    }
    Text {
        id: creator
        text: "Creator"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: about.bottom
        anchors.topMargin: parent.height / 40
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "#BBBB00"
    }
    Text {
        id: name
        text: "Bruno Luvizotto"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: creator.bottom
        anchors.topMargin: parent.height / 40
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "white"
    }
    Text {
        id: email
        text: "E-mail"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: name.bottom
        anchors.topMargin: parent.height / 30
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "#BBBB00"
    }
    Text {
        id: emailText
        text: "brunoluvizotto@gmail.com"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: email.bottom
        anchors.topMargin: parent.height / 40
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "white"
    }
    Text {
        id: linkedIn
        text: "LinkedIn"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: emailText.bottom
        anchors.topMargin: parent.height / 30
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "#BBBB00"
    }
    Text {
        id: linkedInText
        text: "https://br.linkedin.com/pub/bruno-valdrighi-luvizotto/27/8ba/4a6"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: linkedIn.bottom
        anchors.topMargin: parent.height / 40
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "white"
    }
    Text {
        id: pressAnyKeyText
        text: "RETURN"
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: linkedInText.bottom
        anchors.topMargin: parent.height / 30
        font.pixelSize: parent.height / 30
        font.bold: true
        color: "white"
    }

    Timer {
        id: timerPressKey
        running: true
        repeat: true
        interval: 500
        onTriggered: pressAnyKeyText.visible = !pressAnyKeyText.visible
    }
}
