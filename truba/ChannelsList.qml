ListView {
	width: 600;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;
	clip: true;
	delegate: IconTextDelegate { }

	setList(list): {
		var model = this.model;
		model.clear();

		for (var i in list)
			model.append(list[i]);

		this.currentIndex = 0;
	}
}
