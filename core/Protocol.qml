Object {
	signal error;
	property bool enabled: true;
	property bool loading: false;
	property string baseUrl;
	property string url;

	requestImpl(url, data, callback, type, headers): {
		if (!this.enabled)
			return;
		this.loading = true
		if (url.charAt(0) === '/')
			url = url.slice(1)
		this.url = url
		log("request", this.baseUrl + url, data)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: data,
			type: type || 'GET',
			headers: headers || {}
		}).done(function(res) {
			if (callback)
				callback(res)
			self.loading = false 
		}).fail(function(xhr, status, err) {
			log("ajax request failed: " + JSON.stringify(status) + " status: " + xhr.status + " text: " + xhr.responseText)
			if (callback)
				callback({ result: 0, error: { message: "ajax error"} })
			self.loading = false 
			self.error(status)
		})
	}

	request(url, data, callback, type): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url, data, function(res) {
				if (res.error)
					log("Request failed: " + res.error.message);
				else
					callback(res)
			}, type, {})
		}

		do_request()
	}
}
