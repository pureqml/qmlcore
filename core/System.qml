///object for storing general info about device and platform
Object {
	property string userAgent;	///< browser userAgent value
	property string language;	///< platform language
	property string browser;	///< browser name
	property string vendor;		///< current vendor name
	property string os;			///< operation system name
	property bool webkit;		///< webkit supported flag
	property bool support3dTransforms;	///< CSS transforms3d supported flag
	property bool supportTransforms;	///< CSS transforms supported flag
	property bool supportTransitions;	///< CSS transitions supported flag
	property bool portrait: parent.width < parent.height;	///< portrait oriented screen flag
	property bool landscape: !portrait;				///< landscape oriented screen flag
	property bool pageActive: true;					///< page active flag
	property int screenWidth;						///< device screen width value
	property int screenHeight;						///< device screen height value
	property int contextWidth: context.width;		///< @private
	property int contextHeight: context.height;						///< @private
	property enum device { Desktop, Tv, Mobile };	///< device type enumeration, values: Desktop, Tv or Mobile
	property enum layoutType { MobileS, MobileM, MobileL, Tablet, Laptop, LaptopL, Laptop4K };	///< layout type enumeration, values: MobileS, MobileM, MobileL, Tablet, Laptop, LaptopL and Laptop4K

	/// @private
	onContextWidthChanged: { this._updateLayoutType() }
	/// @private
	onContextHeightChanged: { this._updateLayoutType() }

	/// @private
	_updateLayoutType: {
		if (!this.contextWidth || !this.contextHeight)
			return
		var min = this.contextWidth;// < this.contextHeight ? this.contextWidth : this.contextHeight

		if (min <= 320)
			this.layoutType = this.MobileS
		else if (min <= 375)
			this.layoutType = this.MobileM
		else if (min <= 425)
			this.layoutType = this.MobileL
		else if (min <= 768)
			this.layoutType = this.Tablet
		else if (this.contextWidth <= 1024)
			this.layoutType = this.Laptop
		else if (this.contextWidth <= 1440)
			this.layoutType = this.LaptopL
		else
			this.layoutType = this.Laptop4K
	}

	/// @private
	constructor: {
		var ctx = this._context
		this.browser = _globals.core.browser
		this.userAgent = _globals.core.userAgent
		this.device = _globals.core.device
		this.vendor = _globals.core.vendor
		this.os = _globals.core.os
		this.language = _globals.core.language

		ctx.language = this.language.replace('-', '_')
		this.webkit = this.userAgent.toLowerCase().indexOf('webkit') >= 0

		this.support3dTransforms = ctx.backend.capabilities.csstransforms3d || false
		this.supportTransforms = ctx.backend.capabilities.csstransforms || false
		this.supportTransitions = ctx.backend.capabilities.csstransitions || false
	}
}
