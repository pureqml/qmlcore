ListModel {
	setGenres(map): {
		this.clear();
		for (var genre in map) {
			this.append({
				text:	genre,
				list:	map[genre]
			});
		}
	}
}
