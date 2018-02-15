//item for image displaying
Item {
	property int paintedWidth;								///< actually painted image width
	property int paintedHeight;								///< actually painted image height
	property int sourceWidth; 								///< actual width of loaded image
	property int sourceHeight; 								///< actual height of loaded image
	property string source;									///< image URL
	property enum status { Null, Ready, Loading, Error };	///< image status
	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally, Pad };	///< setup mode how image must fill it's content
	property bool smooth: true;								///< if false, image will be pixelated
	property bool preload: false;							///< image will be loaded even if it's not visible

	///@private
	constructor: {
		this._context.backend.initImage(this)
		this._scheduleLoad()
	}

	function getClass() { return 'core-image' }

	///@private
	function _scheduleLoad() {
		if (this.preload || this.recursiveVisible)
			this._context.delayedAction('image.load', this, this._load)
	}

	///@private
	function _onError() {
		this.status = this.Error;
	}

	///@private
	function _load() {
		if (!this.preload && !this.recursiveVisible)
			return

		if (!this.source) {
			this.status = this.Null
			return
		}
		this.status = this.Loading
		this._context.backend.loadImage(this)
	}

	onPreloadChanged,
	onRecursiveVisibleChanged,
	onWidthChanged,
	onHeightChanged,
	onFillModeChanged,
	onSourceChanged: {
		this._scheduleLoad()
	}
}
