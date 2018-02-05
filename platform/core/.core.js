String.prototype.arg = function (arg) {
	for(var i = 1; i < 100; ++i) {
		if (this.indexOf('%' + i) !== -1) {
			var str = this
			while(str.indexOf('%' + i) !== -1)
				str = str.replace('%' + i, arg);
			return str
		}
	}
	return this;
};
