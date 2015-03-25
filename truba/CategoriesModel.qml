ListModel {
	property Protocol protocol;

	update: {
		var self = this;
		this.protocol.getChannels(function(list) {
			self.clear();

			var map = {};
			var defaultName = "Разное";
			for (var i in list) {
				if (!list[i].genres || list[i].genres.length == 0) {
					if (!map[defaultName])
						map[defaultName] = [];
					map[defaultName].push(list[i]);
				} else {
					for (var j in list[i].genres) {
						var genre = list[i].genres[j];
						if (!map[genre])
							map[genre] = [];
						map[genre].push(list[i]);
					}
				}
			}

			for (var genre in map)
				self.append({ text: genre, list: map[genre] });
		})
	}

	onProtocolChanged: { this.update(); }
	onCompleted: { this.update(); }
}
