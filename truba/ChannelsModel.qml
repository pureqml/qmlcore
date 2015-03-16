ListModel {
	property Protocol protocol;

	setList(list): {
		for (var i in list)
			this.append({ text: list[i].title, url: list[i].url, lcn: list[i].url });
	}
}
