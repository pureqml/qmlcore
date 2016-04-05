Item {
	property enum status { Null, Ready, Loading, Error };
	property string source;

	property int paintedWidth;
	property int paintedHeight;

	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally };

	constructor: {
		this._init()
	}

	function _init() {
		var tmp = new Image()
		this._image = tmp
		this._image.onerror = this._onError.bind(this)

		var image = this
		this._image.onload = function() {
			image.paintedWidth = tmp.naturalWidth
			image.paintedHeight = tmp.naturalHeight

			var style = {'background-image': 'url(' + image.source + ')'}
			switch(image.fillMode) {
				case image.Stretch:
					style['background-repeat'] = 'no-repeat'
					style['background-size'] = '100% 100%'
					break;
				case image.TileVertically:
					style['background-repeat'] = 'repeat-y'
					style['background-size'] = '100%'
					break;
				case image.TileHorizontally:
					style['background-repeat'] = 'repeat-x'
					style['background-size'] = tmp.naturalWidth + 'px 100%'
					break;
				case image.PreserveAspectFit:
					style['background-repeat'] = 'no-repeat'
					style['background-position'] = 'center'
					var wPart = image.width / tmp.naturalWidth
					var hPart = image.height / tmp.naturalHeight
					var wRatio = 100
					var hRatio = 100
					if (wPart > hPart)
						wRatio = Math.floor(100 / wPart * hPart)
					else
						hRatio = Math.floor(100 / hPart * wPart)
					style['background-size'] = wRatio + '% ' + hRatio + '%'
					image.paintedWidth = image.width * wRatio / 100
					image.paintedHeight = image.height * hRatio / 100
					break;
				case image.PreserveAspectCrop:
					style['background-repeat'] = 'no-repeat'
					style['background-position'] = 'center'
					var pRatio = tmp.naturalWidth / tmp.naturalHeight
					var iRatio = image.width / image.height
					if (pRatio < iRatio) {
						var hRatio = Math.floor(iRatio / pRatio * 100)
						style['background-size'] = 100 + '% ' + hRatio + '%'
					}
					else {
						var wRatio = Math.floor(pRatio / iRatio * 100)
						style['background-size'] = wRatio + '% ' + 100 + '%'
					}
					break;
				case image.Tile:
					style['background-repeat'] = 'repeat-y repeat-x'
					break;
			}
			image.style(style)

			if (!image.width)
				image.width = image.paintedWidth
			if (!image.height)
				image.height = image.paintedHeight
			image.status = Image.Ready
		}
		this.load()
	}

	function _onError() {
		this.status = this.Error;
	}

	function load() {
		var src = this.source
		this.status = (src.length === 0)? Image.Null: Image.Loading
		this._image.src = src
	}

	function _update(name, value) {
		switch(name) {
			case 'width':
			case 'height':
//			case 'rotate':
			case 'fillMode': this.load(); break;
			case 'source':
				this.status = value ? this.Loading : this.Null;
				if (value)
					this.load();
				break;
		}
		exports.core.Item.prototype._update.apply(this, arguments);
	}

}
