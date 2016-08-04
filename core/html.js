/**
 * @constructor
 */

exports.Element = function(dom) {
	this.dom = dom
}

exports.Element.prototype = Object.create(_globals.core.EventEmitter)
exports.Element.prototype.constructor = exports.Element

exports.Element.prototype.append = function(child) {
	//add element
}

