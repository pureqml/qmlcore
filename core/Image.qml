//item for image displaying
Item {
	property int paintedWidth;								///< actually painted image width
	property int paintedHeight;								///< actually painted image height
	property int sourceWidth; 								///< actual width of loaded image
	property int sourceHeight; 								///< actual height of loaded image
	property string source;									///< image URL
	property enum status { Null, Ready, Loading, Error };	///< image status
	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally, Pad };	///< setup mode how image must fill it's content

	///@private
	constructor: {
		var self = this
		this._delayedLoad = new _globals.core.DelayedAction(this._context, function() {
			self._load()
		})

		this._context.backend.initImage(this)
		this.load()
	}

	///@private
	function _onError() {
		this.status = this.Error;
	}

	///@private
	function _load() {
		this._context.backend.loadImage(this)
	}

	///@private
	function load() {
		this.status = (this.source.length === 0) ? Image.Null: Image.Loading
		this._delayedLoad.schedule()
	}

	///@private
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
