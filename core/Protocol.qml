Object {
	signal error;
	property bool enabled: true;
	property bool loading: false;
	property string baseUrl;
	property string url;

	requestImpl(url, data, callback, type, headers, dataType): {
		if (!this.enabled)
			return;
		this.loading = true
		this.url = url
		log("request", this.baseUrl + url)

		var settings = {
			url: this.baseUrl + url,
			type: type || 'GET',
			headers: headers || {}
		}

		if (dataType)
			settings.dataType = dataType

		if (data)
			settings.data = JSON.stringify(data)

		var self = this;
		$.ajax(settings).done(function(res, status, jqXHR) {
			log("ajax request done")
			if (callback)
				callback(res, status, jqXHR)
			self.loading = false 
		}).fail(function(xhr, status, err) {
			log("ajax request failed: " + JSON.stringify(status) + " status: " + xhr.status + " text: " + xhr.responseText)
			if (callback)
				callback({ result: 0, error: { message: "ajax error"} })
			self.loading = false 
			self.error(status, xhr, self.url, type || 'GET')
		})
	}

	request(url, callback, type, headers, data, dataType): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url, data, function(res, status, jqXHR) {
				if (!res) {
					log("No content");
					callback(res, status, jqXHR)
				} else if (res.error) {
					log("Request failed: " + res.error.message);
				} else {
					callback(res, status, jqXHR)
				}
			}, type, headers, dataType)
		}

		do_request()
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
