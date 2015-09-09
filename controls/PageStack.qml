Item {
	property int currentIndex: 0;
	property int count: 0;

	update: {
		this.count = this.children.length;
		for (var i = 0; i < this.children.length; ++i)
			this.children[i].visible = (i == this.currentIndex);
	}

	onCurrentIndexChanged: {
		if (this.currentIndex < 0)
			this.currentIndex = 0;
		else if (this.currentIndex >= this.children.length)
			this.currentIndex = this.children.length - 1;
			
		this.update();
	}

	onCompleted: { this.update(); }
}
