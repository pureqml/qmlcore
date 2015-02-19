ListModel {
	setList(list): {
		var model = this;
		list.channels.forEach(function(id) { model.append({id: id}); } )
	}
	prepare(asset): { }
	getUrl(idx): {
		var row = this.get(idx)
		var id = 0
		row.asset.resources.forEach(function(res) {
			if (res.category == "hls")
				id = res.id
		})
		if (!id)
			throw "no hls stream found"

		this.protocol.getUrl('', row.id, id, function(res) {
			console.log('URL', res)
		})
	}
	get(idx): {
		var row = this._rows[idx]
		if (row.asset)
			return row;

		var model = this
		var id = row.id
		this.protocol.getAsset(id, function(res) {
			console.log("asset", id, res)
			model.prepare(res)
			model.setProperty(idx, "asset", res)
		})
		return row;
	}
}
