/// class controlling object transformation
Object {
	property int translateX;
	property int translateY;
	property int translateZ;
	property real rotate;
	property real rotateX;
	property real rotateY;
	property real rotateZ;
	property real skewX;
	property real skewY;

	function _update(name, value) {
		switch(name) {
			case 'translateX':	this.parent.style('transform', 'translateX(' + value + 'px)'); break;
			case 'translateY':	this.parent.style('transform', 'translateY(' + value + 'px)'); break;
			case 'translateZ':	this.parent.style('transform', 'translateZ(' + value + 'px)'); break;
			case 'rotate':	this.parent.style('transform', 'rotate(' + value + 'deg)'); break
			case 'rotateX':	this.parent.style('transform', 'rotateX(' + value + 'deg)'); break
			case 'rotateY':	this.parent.style('transform', 'rotateY(' + value + 'deg)'); break
			case 'rotateZ':	this.parent.style('transform', 'rotateZ(' + value + 'deg)'); break
			case 'skewX':	this.parent.style('transform', 'skewX(' + value + 'deg)'); break
			case 'skewY':	this.parent.style('transform', 'skewY(' + value + 'deg)'); break
		}
		_globals.core.Object.prototype._update.apply(this, arguments)
	}
}
