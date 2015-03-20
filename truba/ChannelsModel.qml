ListModel {
	property Protocol protocol;

	setList(list): {
		for (var i in list)
			this.append({
				text:	list[i].title,
				url:	list[i].url,
				lcn:	list[i].url,
				source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : ""
			});
	}
}
