Item {
	property enum status { Null, Ready, Loading, Error };
	property string source;

	property int paintedWidth;
	property int paintedHeight;

	property enum fillMode { Stretch, PreserveAspectFit, PreserveAspectCrop, Tile, TileVertically, TileHorizontally };

	constructor: {
		this._init()
	}
}
