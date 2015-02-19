ListModel {
	setList(list): {
		var model = this;
		list.channels.forEach(function(id) { model.append({id: id}); } )
	}
	get(idx): {
		if (typeof idx == 'string')
			return _globals.core.Object.prototype.get.apply(this, arguments)

		var row = this._rows[idx]
		if (row.asset)
			return row;

		var model = this
		var id = row.id
		this.protocol.getAsset(id, function(res) {
			console.log("asset", id, res)
			model.setProperty(idx, "asset", res)
		})
		return row;
	}
}
