ListModel {
	subscribeOrigins: {
		if (this._originChangedCallback)
			return;
		this._protocol = this.protocol
		this._originChangedCallback = (function() {
			this.reset()
			for(var i = 0; i < this._rows.length; ++i)
				try { this.prepare(this._rows[i]) } catch(ex) { log("prepare failed", ex, ex.stack) }
		}).bind(this)
		this.protocol.onChanged('originList', this._originChangedCallback)
	}

	onProtocolChanged: {
		if (this._originChangedCallback)
			this._protocol.removeOnChanged('originList', this._originChangedCallback)
		this._originChangedCallback = undefined

		if (!this.protocol)
			return

		this.subscribeOrigins()
	}

	setList(list): {
		this.clear()
		if (!list || !list.channels) {
			log("setList called with empty list.channel", list)
			return
		}
		this.subscribeOrigins()
		var self = this;
		this.protocol.getAssets(list.channels, function(assets) {
			assets.sort(function(a, b) {
				return a.er_lcn - b.er_lcn
			})
			assets.forEach(
				function(asset) {
					try { self.prepare(asset) } catch(ex) { log("prepare failed", ex, ex.stack) }
					self.append(asset)
				}
			)
		})
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
		//log("PREPARE", res.hlsId, res.pictureId, res.pictureUrl)
	}

	getUrl(idx, callback): {
		var row = this.get(idx)
		this.protocol.getUrl(row.id, row.hlsStreamId, function(res) {
			callback(res.url)
		})
	}
}
