/// @private this object minimally represent Object contract, use for immutable simple object like AnchorLine
CoreObject {
	constructor: { this.parent = parent; this.__properties = {} }
	function _removeUpdater() { }
}
