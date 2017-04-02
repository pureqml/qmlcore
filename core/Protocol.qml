///object for handling XML/HTTP requests
Object {
	property bool loading: false;	///< loading flag, is true when request was send and false when answer was recieved or error occured

	/**@param request:Object request object
	send request using 'fetch' method*/
	fetchRequest(request): {
		var url = request.url
		var error = request.errorCallback,
			data = request.data,
			headers = request.headers,
			callback = request.callback,
			settings = request.settings

		this.loading = true
		var self = this

		fetch(url, {
				method: request.type || 'GET',
				header: headers || {},
				body: request.body || ''
			})
			.then(function(response) {
				if (callback)
					callback(response)
				self.loading = false
			})
			.catch(function(err) {
				if (error)
					error(err)
				self.loading = false
			})
	}

	/**@param request:Object request object
	send request using 'XMLHttpRequest' object*/
	requestXHR(request): {
		var url = request.url
		var xhr = new XMLHttpRequest()
		var error = request.errorCallback,
			data = request.data,
			headers = request.headers,
			callback = request.callback,
			settings = request.settings

		var self = this
		if (error)
			xhr.addEventListener('error', function(event) { self.loading = false; log("Error"); error(event) })

		if (callback)
			xhr.addEventListener('load', function(event) { self.loading = false; callback(event) })

		xhr.open(request.type || 'GET', url);

		if (request.withCredentials)
			request.withCredentials = true

		for (var i in settings)
			xhr[i] = settings[i]

		for (var i in headers)
			xhr.setRequestHeader(i, headers[i])

		this.loading = true
		if (request.data)
			xhr.send(request.data)
		else
			xhr.send()
	}
}
