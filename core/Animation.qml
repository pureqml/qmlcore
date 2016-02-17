Object {
	property int duration: 200;
	property bool cssTransition: false;
	property bool running: false;

	disable:	{ ++this._disabled; }
	enable:		{ --this._disabled; }
	enabled:	{ return this._disabled == 0; }
}
