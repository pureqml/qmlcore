ListModel {
	property string providers;

	update: {
		if (!this.protocol)
			return;

		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			var providersMap = self.providers? JSON.parse(self.providers): {};
			var defaultGenre = "Разное";
			var map = {};

			for (var i in list) {
				if (providersMap && !providersMap[list[i].provider])
					continue;

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
}
