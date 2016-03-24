Item {
	property enum status { Null, Ready, Loading, Error };
	property string source;

	property int paintedWidth;
	property int paintedHeight;

	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally };

	constructor: {
		this.element.on('load', this._onLoad.bind(this));
		this.element.on('error', this._onError.bind(this));
	}
}
