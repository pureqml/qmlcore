Rectangle {
	//width: parent.cellWidth;
	//height: parent.cellHeight;
	//color: model.color;
	//z: activeFocus ? parent.z + 100 : parent.z + 1;

	//AlphaControl { alphaFunc: MaxAlpha; }

	//Rectangle {
		//id: channelBgPanel;
		//anchors.centerIn: parent;
		//width: parent.activeFocus ? parent.width + 20 : parent.width;
		//height: parent.activeFocus ? width - 40 : parent.height;
		//color: model.color;
		//visiible: parent.activeFocus;

		//Behavior on width { animation: Animation { duration: 200; } }
	//}

	//Rectangle {
		//id: titleBgPanel;
		//height: parent.activeFocus ? channelDelegateLabel.paintedHeight : 0;
		//anchors.top: channelBgPanel.bottom;
		//anchors.left: channelBgPanel.left;
		//anchors.right: channelBgPanel.right;
		//color: colorTheme.activeFocusColor;
		//clip: true;

		//Text {
			//id: channelDelegateLabel;
			//anchors.top: parent.top;
			//anchors.left: parent.left;
			//anchors.right: parent.right;
			//horizontalAlignment: AlignHCenter;
			//wrapMode: Text.Wrap;
			//text: model.text;
			//color: colorTheme.focusedTextColor;
			//font.pixelSize: 10;
		//}
	//}

	//BorderShadow3D {
		//anchors.top: channelBgPanel.top;
		//anchors.left: channelBgPanel.left;
		//anchors.right: channelBgPanel.right;
		//anchors.bottom: titleBgPanel.bottom;
		//visible: parent.activeFocus;
	//}

	//Image {
		//anchors.fill: parent;
		//anchors.margins: 10;
		//fillMode: Image.PreserveAspectFit;
		//source: model.source;
	//}
}
