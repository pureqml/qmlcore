//item for image displaying
Item {
	property int paintedWidth;								///< actually painted image width
	property int paintedHeight;								///< actually painted image height
	property int sourceWidth; 								///< actual width of loaded image
	property int sourceHeight; 								///< actual height of loaded image
	property string source;									///< image URL
	property enum status { Null, Ready, Loading, Error };	///< image status
	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally, Pad };	///< setup mode how image must fill it's content
	property enum verticalAlignment { AlignVCenter, AlignTop, AlignBottom };
	property enum horizontalAlignment { AlignHCenter, AlignLeft, AlignRight };
	property bool smooth: true;								///< if false, image will be pixelated
	property bool preload: false;							///< image will be loaded even if it's not visible

	width: sourceWidth;
	height: sourceHeight;

	///@private
	constructor: {
		this._context.backend.initImage(this)
		this._scheduleLoad()
	}

	htmlClass: "core-image";

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
		if (this.status === this.Ready) {
			this._updatePaintedSize()
			return
		}

		if (!this.preload && !this.recursiveVisible)
			return

		if (!this.source) {
			this._resetImage()
			return
		}

		this.status = this.Loading
		var ctx = this._context
		var callback = this._imageLoaded.bind(this)
		ctx.backend.loadImage(this, ctx.wrapNativeCallback(callback))
	}

	onPreloadChanged,
	onRecursiveVisibleChanged,
	onWidthChanged,
	onHeightChanged,
	onFillModeChanged: {
		this._scheduleLoad()
	}

	onSourceChanged: {
		this.status = this.Null
		this._scheduleLoad()
	}

	///@private
	function _resetImage() {
		this.style('background-image', '')
	}

	function _updatePaintedSize() {
		var natW = this.sourceWidth, natH = this.sourceHeight
		var w = this.width, h = this.height

		if (natW <= 0 || natH <= 0 || w <= 0 || h <= 0) {
			this.paintedWidth = 0
			this.paintedHeight = 0
			return
		}

		var crop
		switch(this.fillMode) {
			case ImageComponent.PreserveAspectFit:
				crop = false
				break
			case ImageComponent.PreserveAspectCrop:
				crop = true
				break
			default:
				this.paintedWidth = w
				this.paintedHeight = h
				return
		}

		var targetRatio = w / h, srcRatio = natW / natH

		var useWidth = crop? srcRatio < targetRatio: srcRatio > targetRatio
		if (useWidth) { // img width aligned with target width
			this.paintedWidth = w;
			this.paintedHeight = w / srcRatio;
		} else {
			this.paintedHeight = h;
			this.paintedWidth = h * srcRatio;
		}
	}

	///@private
	function _imageLoaded(metrics) {
		if (!metrics) {
			this.status = ImageComponent.Error
			return
		}

		var style = { 'background-image': 'url("' + this.source + '")' }

		var natW = metrics.width, natH = metrics.height
		this.sourceWidth = natW
		this.sourceHeight = natH

		switch(this.horizontalAlignment) {
			case ImageComponent.AlignHCenter:
				style['background-position-x'] = 'center'
				break;
			case ImageComponent.AlignLeft:
				style['background-position-x'] = 'left'
				break;
			case ImageComponent.AlignRight:
				style['background-position-x'] = 'right'
				break;
		}

		switch(this.verticalAlignment) {
			case ImageComponent.AlignVCenter:
				style['background-position-y'] = 'center'
				break;
			case ImageComponent.AlignTop:
				style['background-position-y'] = 'top'
				break;
			case ImageComponent.AlignBottom:
				style['background-position-y'] = 'bottom'
				break;
		}

		switch(this.fillMode) {
			case ImageComponent.Stretch:
				style['background-repeat'] = 'no-repeat'
				style['background-size'] = '100% 100%'
				break;
			case ImageComponent.TileVertically:
				style['background-repeat'] = 'repeat-y'
				style['background-size'] = '100% ' + natH + 'px'
				break;
			case ImageComponent.TileHorizontally:
				style['background-repeat'] = 'repeat-x'
				style['background-size'] = natW + 'px 100%'
				break;
			case ImageComponent.Tile:
				style['background-repeat'] = 'repeat-y repeat-x'
				style['background-size'] = 'auto'
				break;
			case ImageComponent.PreserveAspectCrop:
				style['background-repeat'] = 'no-repeat'
				style['background-size'] = 'cover'
				break;
			case ImageComponent.Pad:
				style['background-repeat'] = 'no-repeat'
				style['background-position'] = '0% 0%'
				style['background-size'] = 'auto'
				break;
			case ImageComponent.PreserveAspectFit:
				style['background-repeat'] = 'no-repeat'
				style['background-size'] = 'contain'
				break;
		}
		style['image-rendering'] = this.smooth? 'auto': 'pixelated'
		this.style(style)

		this.status = ImageComponent.Ready
		this._updatePaintedSize()
	}
}
