Object {
	property int duration: 200;

	disable:	{ ++this._disabled; }
	enable:		{ --this._disabled; }
	enabled:	{ return this._disabled == 0; }
}
