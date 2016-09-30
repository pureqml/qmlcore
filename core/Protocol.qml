Object {
	property bool loading: false;
	property string baseUrl;
	property string url;

	fetchRequest(request): {
		var url = this.baseUrl + request.url
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

	requestXHR(request): {
		var url = this.baseUrl + request.url
		var xhr = new XMLHttpRequest()
		var error = request.errorCallback,
			data = request.data,
			headers = request.headers,
			callback = request.callback,
			settings = request.settings

		if (error)
			xhr.addEventListener('error', function(event) { log("Error");error(event) })

		if (callback)
			xhr.addEventListener('load', function(event) { log("Done"); callback(event) })

		xhr.open(request.type || 'GET', url);

		for (var i in settings)
			xhr[i] = settings[i]

		for (var i in headers)
			xhr.setRequestHeader(i, settings[i])

		log("request", url)
		if (request.data)
			xhr.send(request.data)
		else
			xhr.send()
	}
}
