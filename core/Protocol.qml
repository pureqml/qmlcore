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
		this.url = url
		log("request", this.baseUrl + url)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: JSON.stringify(data),
			type: type || 'GET',
			headers: headers || {}
		}).done(function(res, status, jqXHR) {
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

	request(url, data, callback, type, headers): {
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
					callback(res)
				}
			}, type, headers)
		}

		do_request()
	}
}
