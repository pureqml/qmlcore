Rectangle {
    id: button;
    signal triggered;

    width: 145; height: 60;
    color: "blue";
    smooth: true;
    focus: true;
    property alias text: label.text;
    property alias textColor: label.color;

    color: activeFocus ? "red": "blue";
    opacity: activeFocus ? 1 : 0.5;
    textColor: activeFocus ? "black" : "white";

    Behavior on opacity	{ Animation { duration: 400; } }
    Behavior on color	{ ColorAnimation { duration: 400; } }

/*
     gradient: Gradient {
         GradientStop {color: "#CFF7FF"; position: 0.0; }
         GradientStop {color: "#99C0E5"; position: 0.57; }
         GradientStop {color: "#719FCB"; position: 0.9; }
     }

*/
    Text {
        id: label;
        anchors.centerIn: parent;
        font.pointSize: 12;
        color: "white";

        Behavior on color   { ColorAnimation { duration: 400; } }
    }

    MouseArea {
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: { button.triggered(); }
        onEntered: { button.forceActiveFocus(); }
    }

    onSelectPressed: { this.triggered(); }
    onTriggered: { console.log(button.text + " triggered"); }
}
