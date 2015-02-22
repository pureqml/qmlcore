Rectangle {
    id: button;
    signal triggered;

    width: 145; height: 60;
    color: "blue";
    smooth: true;
    focus: true;
    clip: true;
    property alias text: label.text;
    property alias textColor: label.color;

    color: activeFocus ? "red": "blue";
    opacity: activeFocus ? 1 : 0.5;
    textColor: activeFocus ? "black" : "white";

    Behavior on opacity	{ Animation { duration: 300; } }
    Behavior on color	{ ColorAnimation { duration: 300; } }

    Text {
        id: label;
        anchors.centerIn: parent;
        font.pointSize: 18;
        color: "white";

        Behavior on color   { ColorAnimation { duration: 300; } }
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;

        z: 100;
        onClicked: { button.triggered(); }
        onEntered: { 
            if (!button.activeFocus)
                button.forceActiveFocus(); 
        }
    }

    onSelectPressed: { this.triggered(); }
    onTriggered: { console.log(button.text + " triggered"); }
}
