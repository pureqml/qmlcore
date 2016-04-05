Object {
	property string family;
	property bool italic;
	property bool bold;
	property bool underline;
	property bool shadow;
	property int pixelSize;
	property int pointSize;
	property int lineHeight;
	property int weight;

	function _update(name, value) {
		switch(name) {
			case 'family':		this.parent.style('font-family', value); this.parent._updateSize(); break
			case 'pointSize':	this.parent.style('font-size', value + "pt"); this.parent._updateSize(); break
			case 'pixelSize':	this.parent.style('font-size', value + "px"); this.parent._updateSize(); break
			case 'italic': 		this.parent.style('font-style', value? 'italic': 'normal'); this.parent._updateSize(); break
			case 'bold': 		this.parent.style('font-weight', value? 'bold': 'normal'); this.parent._updateSize(); break
			case 'underline':	this.parent.style('text-decoration', value? 'underline': ''); this.parent._updateSize(); break
			case 'shadow':		this.parent.style('text-shadow', value? '1px 1px black': 'none'); this.parent._updateSize(); break;
			case 'lineHeight':	this.parent.style('line-height', value + "px"); this.parent._updateSize(); break;
			case 'weight':	this.parent.style('font-weight', value); this.parent._updateSize(); break;
		}
		qml.core.Object.prototype._update.apply(this, arguments);
	}


}
