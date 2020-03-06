///object for handling XML/HTTP requests
Object {
	property bool loading: false;	///< loading flag, is true when request was send and false when answer was recieved or error occured

	/**@param request:Object request object
	send request using 'XMLHttpRequest' object*/
	function ajax(request) {
		if (request.done)
			request.done = this._context.wrapNativeCallback(request.done)
		if (request.error)
			request.error = this._context.wrapNativeCallback(request.error)
		this._context.backend.ajax(this, request)
	}
}
