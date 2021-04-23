/// object that helps loading components dynamically
Item {
	signal loaded;				///< when requested component it loaded event signal
	signal itemCompleted;		///< fires after item onCompleted has been fired and item is fully constructed
	property string source;		///< component's URL
	property Object item;		///< item for storing requested component
	property bool trace;		///< log loading objects

	///@private
	function discardItem() {
		var item = this.item
		if (item) {
			item.discard()
			item = null
		}
	}

	///@private
	function discard() {
		this.discardItem()
		$core.Item.prototype.discard.call(this)
	}

	///@internal
	onSourceChanged: {
		this.discardItem()
		this._load()
	}

	///@internal
	function _load() {
		var source = this.source
		if (!source)
			return

		if (this.trace)
			log('loading ' + source + '…')
		var path = source.split('.')
		var ctor = _globals
		while(path.length) {
			var ns = path.shift()
			ctor = ctor[ns]
			if (ctor === undefined)
				throw new Error('unknown component used: ' + source)
		}

		var item = this.item = new ctor(this)
		var overrideComplete = oldComplete !== $core.CoreObject.prototype.__complete

		if (overrideComplete) {
			var oldComplete = item.__complete
			var itemCompleted = this.itemCompleted.bind(this, item)
			item.__complete = function() {
				try {
					oldComplete.call(this)
				} catch(ex) {
					log("onComplete failed:", ex)
				}
				itemCompleted()
			}
		}

		$core.core.createObject(item)
		this.loaded(item)

		if (!overrideComplete)
			this.itemCompleted()
	}

	onRecursiveVisibleChanged: {
		if (this.item)
			this._updateVisibilityForChild(this.item, value)
	}

	///@internal
	onCompleted: {
		if (!this.item && this.source)
			this._load()
	}
}
