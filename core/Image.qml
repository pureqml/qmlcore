Item {
	property enum status { Null, Ready, Loading, Error };	///< image status
	property string source;									///< image URL

	property int paintedWidth;								///< real image width
	property int paintedHeight;								///< real image height

	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally, Pad };

	constructor: {
		var self = this
		this._delayedLoad = new _globals.core.DelayedAction(this._context, function() {
			self._load()
		})

		this._context.backend.initImage(this)
		this.load()
	}

	function _onError() {
		this.status = this.Error;
	}

	function _load() {
		this._context.backend.loadImage(this)
	}

	function load() {
		this.status = (this.source.length === 0) ? Image.Null: Image.Loading
		this._delayedLoad.schedule()
	}

	function _update(name, value) {
		switch(name) {
			case 'width':
			case 'height':
			case 'fillMode': this.load(); break;
			case 'source':
				this.status = value ? this.Loading : this.Null;
				if (value)
					this.load();
				break;
		}
		_globals.core.Item.prototype._update.apply(this, arguments);
	}

}
