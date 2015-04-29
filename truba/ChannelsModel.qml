ListModel {
	getColor: {
		var colors = ["#CE93D8", "#FF8A80", "#90CAF9", "#80CBC4", "#F0F4C3", "#D7CCC8", "#FFCCBC"];
		return colors[Math.round(Math.random() * (colors.length - 1))];
	}

	setList(list): {
		this.clear();
		for (var i = 0; i < list.length; ++i) {
			var channelColor = list[i].icon ? list[i].icon.color : this.getColor();
			this.append({
				text:	list[i].title,
				url:	list[i].url,
				lcn:	list[i].lcn,
				source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : "",
				color:	channelColor
			});
		}
	}
}
