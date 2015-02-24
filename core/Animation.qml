Object {
	property int duration: 200;

	disable:	{ ++this._disable; }
	enable:		{ --this._disable; }
	enabled:	{ return this._disabled == 0; }
}
