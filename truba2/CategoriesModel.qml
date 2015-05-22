ListModel {
	property string provider;

	update: {
		if (!this.protocol)
			return;

		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			if (!self.provider) {
				log("Provider is undefined.");
				return;
			}

			var defaultGenre = "Разное";
			var map = {};

			for (var i in list) {
				if (self.provider != list[i].provider)
					continue;

				if (!list[i].genres || list[i].genres.length == 0) {
					if (!map[defaultGenre])
						map[defaultGenre] = [];
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

	onProviderChanged:			{ this.update(); }
	onCompleted:				{ this.update(); }
	onProtocolChanged:			{ this.update(); }
}
