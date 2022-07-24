/// object that helps loading components dynamically
Item {
	signal loaded;				///< signals loaded component (first argument)
	signal itemCompleted;		///< fires after item onCompleted has been fired and item is fully constructed
	property string source;		///< component's URL
	property Component sourceComponent; ///< loads delegate from component.
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
	onSourceComponentChanged: {
		this.discardItem()
		this._load()
	}

	function _loadSource() {
		var source = this.source
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
		return new ctor(this)
	}

	///@internal
	function _load() {
		var item
		if (this.source) {
			item = this._loadSource()
		} else if (this.sourceComponent) {
			if (!(this.sourceComponent instanceof $core.Component))
				throw new Error("sourceComponent assigned to Loader " + this.getComponentPath() + " is not an instance of Component")
			if (this.trace)
				log('loading component ' + this.sourceComponent.getComponentPath())
			var row = this.parent._get('model', true)
			item = this.sourceComponent.delegate(this, row? row: {})
		} else
			return

		this.item = item
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
		if (!this.item && (this.source || this.sourceComponent))
			this._load()
	}
}
