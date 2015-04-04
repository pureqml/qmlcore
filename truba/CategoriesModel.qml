ListModel {
	property Protocol	protocol;

	update: {
		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			var defaultGenre = "Разное";
			var map = {};

			for (var i in list) {
				if (!map[defaultGenre])
					map[defaultGenre] = [];

				if (!list[i].genres || list[i].genres.length == 0) {
					map[defaultGenre].push(list[i]);
				} else {
					for (var j in list[i].genres) {
						var genre = list[i].genres[j];
						if (!map[genre])
							map[genre] = [];
						map[genre].push(list[i]);
					}
				}
			}

			for (var genre in map) {
				self.append({
					text: genre,
					list: map[genre]
				});
			}
		})
	}

	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
	onShowActivatedOnlyChanged:	{ this.update(); }
}
