// RUN: %build
// RUN: grep "delegate.width = delegate.parent.parent.w0" %out/qml.gh205.js

Item {
    anchors.fill: context;
    property color defaultColor: "blue";
    Rectangle {
	anchors.fill: parent;
	color: parent.defaultColor;
    }

    property int w0: width/5;

    ListView {
	model: ListModel {
	    ListElement { value: "foo"; }
	    ListElement { value: "bar"; }
	    ListElement { value: "baz"; }
	}
	anchors.fill: parent;
	delegate: Rectangle {
	    color: defaultColor;
	    width: w0;
	    height: parent.parent.w0;
	    Rectangle {
		anchors.margins: 10;
		anchors.fill: parent;
		color: "red";
		Text {
		    anchors.centerIn: parent;
		    color: "white";
		    text: model.value + " " + w0;
		}
		width: 100;
		height: 100;
	    }
	}
    }
}
