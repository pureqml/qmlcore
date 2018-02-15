var getTime = function() { return Math.floor(new Date().getTime() / 1000) }

var Entry = function() {
	this.created = getTime()
	this.waiters = []
	this.invoker = null
}

Entry.prototype.expired = function(ttl) {
	return getTime() - this.created >= ttl
}

Entry.prototype.set = function(result) {
	this.created = getTime()
	var invoker = this.invoker = _globals.core.safeCall(null, [result], function(ex) { log("cache entry callback failed: ", ex, ex.stack) })
	while(this.waiters.length) {
		var waiters = this.waiters
		this.waiters = []
		waiters.forEach(invoker)
	}
	this.waiters = null
}

Entry.prototype.wait = function(callback) {
	if (this.invoker !== null)
		this.invoker(callback)
	else
		this.waiters.push(callback)
}

var Cache = function(create, ttl) {
	if (!create)
		throw new Error("create callback is required")
	this._create = create
	this._ttl = ttl || 3600
	this._cache = {}
	setInterval(this.cleanup.bind(this), this._ttl / 2 * 1000)
}

Cache.prototype.get = function(key, callback) {
	var entry = this._cache[key]
	if (entry === undefined || entry.expired(this._ttl)) {
		this._cache[key] = entry = new Entry()
		this._create(key, function(result) {
			entry.set(result)
		})
	}
	entry.wait(callback)
}

Cache.prototype.cleanup = function() {
	for(var k in this._cache) {
		var entry = this._cache[k]
		if (entry.expired(this._ttl)) {
			delete this._cache[k]
		}
	}
}

exports.Cache = Cache
