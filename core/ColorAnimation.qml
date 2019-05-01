///Animation for color-typed properties
Animation {
	///@private
	function interpolate(dst, src, t) {
		var blend = $core.Animation.prototype.interpolate
		var dst_c = new $core.Color(dst), src_c = new $core.Color(src);
		var r = Math.floor(blend(dst_c.r, src_c.r, t))
		var g = Math.floor(blend(dst_c.g, src_c.g, t))
		var b = Math.floor(blend(dst_c.b, src_c.b, t))
		var a = Math.floor(blend(dst_c.a, src_c.a, t))
		return "rgba(" + r + "," + g + "," + b + "," + a + ")";
	}
}
