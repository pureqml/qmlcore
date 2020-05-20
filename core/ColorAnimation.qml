///Animation for color-typed properties
Animation {
	///@private
	function interpolate(dst, src, t) {
		return $core.Color.interpolate(dst, src, t)
	}
}
