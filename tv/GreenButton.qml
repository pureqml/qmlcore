 Rectangle {
    id: domButton;
    signal triggered;

    width: 145; height: 60;
    color: "green";
    smooth: true;
    focus: true;
    property alias text: label.text;

    color: activeFocus ? "#539d00" : "black";
    opacity: activeFocus ? 1 : 0.6;

    Behavior on opacity	{ Animation { duration: 300; } }
    Behavior on height  { Animation { duration: 300; } }
    Behavior on color	{ ColorAnimation { duration: 300; } }

    Text {
        id: label;
        anchors.centerIn: parent;
        font.pointSize: 12;
        color: "white";
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: { domButton.triggered(); }
        onEntered: { domButton.forceActiveFocus(); }
    }

    onSelectPressed: { this.triggered(); }
}