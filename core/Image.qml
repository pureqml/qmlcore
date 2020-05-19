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
		if (this.status === this.Ready || (!this.preload && !this.recursiveVisible))
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

		if (this.fillMode !== ImageComponent.PreserveAspectFit) {
			this.paintedWidth = this.width
			this.paintedHeight = this.height
		}

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
				var w = this.width, h = this.height
				var targetRatio = 0, srcRatio = natW / natH

				if (w && h)
					targetRatio = w / h

				if (srcRatio > targetRatio && w) { // img width aligned with target width
					this.paintedWidth = w;
					this.paintedHeight = w / srcRatio;
				} else {
					this.paintedHeight = h;
					this.paintedWidth = h * srcRatio;
				}
				break;
		}
		style['image-rendering'] = this.smooth? 'auto': 'pixelated'
		this.style(style)

		this.status = ImageComponent.Ready
	}
}
