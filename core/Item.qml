Object {
	property int x;
	property int y;
	property int z;
	property int width;
	property int height;
	property bool clip;

	property bool focus;
	property bool activeFocus;
	property Item focusedChild;

	property bool visible: true;
	property real opacity: 1;

	property Anchors anchors: Anchors { }

	property AnchorLine left: AnchorLine	{ boxIndex: 0; }
	property AnchorLine top: AnchorLine		{ boxIndex: 1; }
	property AnchorLine right: AnchorLine	{ boxIndex: 0; }
	property AnchorLine bottom: AnchorLine	{ boxIndex: 1; }

	property AnchorLine horizontalCenter:	AnchorLine	{ boxIndex: 0; }
	property AnchorLine verticalCenter:		AnchorLine	{ boxIndex: 1; }

	//do not use, view internal
	property int viewX;
	property int viewY;
}
