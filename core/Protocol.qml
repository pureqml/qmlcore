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
			data: JSON.stringify(data),
			type: type || 'GET',
			headers: headers || {}
		}

		if (dataType)
			settings.dataType = dataType

		var self = this;
		$.ajax(settings).done(function(res) {
			if (callback)
				callback(res)
			self.loading = false 
		}).fail(function(xhr, status, err) {
			log("ajax request failed: " + JSON.stringify(status) + " status: " + xhr.status + " text: " + xhr.responseText)
			if (callback)
				callback({ result: 0, error: { message: "ajax error"} })
			self.loading = false 
			self.error(status, self.url, type || 'GET')
		})
	}

	request(url, data, callback, type, headers, dataType): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url, data, function(res) {
				if (!res) {
					log("No content");
					callback(res)
				} else if (res.error) {
					log("Request failed: " + res.error.message);
				} else {
					callback(res)
				}
			}, type, headers, dataType)
		}

		do_request()
	}
}
