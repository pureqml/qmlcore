ListModel {
	setList(list): {
		this.clear();

		for (var i = 0; i < list.length; ++i)
			this.append({
				text:	list[i].title,
				url:	list[i].url,
				lcn:	list[i].lcn,
				source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : "",
				color:	list[i].icon ? list[i].icon.color : "#fff"
			});
	}
}
