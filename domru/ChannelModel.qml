ListModel {
	setList(list): {
		var self = this;
		list.channels.forEach(function(id) { self.append({id: id}); } )
	}

	prepare(res): {
		var id = 0, pictureId = 0, pictureUrl

		var self = this
		res.resources.forEach(function(res) {
			if (res.category == "hls")
				id = res.id
			else if (res.type == "picture") {
				pictureId = res.id
				pictureUrl = self.protocol.resolveResource(res)
			}
		})
		if (!id)
			throw "no hls stream found"
		res.hlsStreamId = id;
		res.pictureId = pictureId
		res.pictureUrl = pictureUrl
		//console.log("PREPARE", res.hlsId, res.pictureId, res.pictureUrl)
	}

	getUrl(idx, callback): {
		this.get(idx, (function(row) {
			this.protocol.getUrl(row.id, row.asset.hlsStreamId, function(res) {
				callback(res.url)
			})
		}).bind(this))
	}
	get(idx, callback): {
		var row = this._rows[idx]
		if (row.asset) {
			if (callback)
				callback(row)
			return row;
		}

		var self = this
		var id = row.id
		this.protocol.getAsset(id, function(res) {
			console.log("asset", id, res)
			self.prepare(res)
			self.setProperty(idx, "asset", res)
			if (callback)
				callback(this._rows[idx])
		})
		return row;
	}
}
