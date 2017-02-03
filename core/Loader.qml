Item {
	signal loaded;

	property string source;
	property Object item;

	function discardItem() {
		var item = this.item
		if (item) {
			item.discard()
			item = null
		}
	}

	function discard() {
		this.discardItem()
		_globals.core.Item.prototype.discard.call(this)
	}

	onSourceChanged: {
		this.discardItem()
		this._load()
	}

	function _load() {
		var source = this.source
		if (!source)
			return

		log('loading ' + source + '...')
		var path = source.split('.')
		var ctor = _globals
		while(path.length) {
			var ns = path.shift()
			ctor = ctor[ns]
			if (ctor === undefined)
				throw new Error('unknown component used: ' + source)
		}
		var item = new ctor(this)
		var closure = {}
		item.__create(closure)
		item.__setup(closure)
		this.item = item
		this.loaded()
	}

	onCompleted: {
		this._load()
	}
}
