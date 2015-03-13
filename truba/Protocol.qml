Object {
	signal error;
	property string baseUrl;

	getChannels(callback): {
		this.request("/channels", {}, callback)
	}

	requestImpl(url, data, callback, type, headers): {
		if (!this.enabled)
			return;
		if (url.charAt(0) === '/')
			url = url.slice(1)
		log("request", url, data)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: data,
			type: type || 'GET',
			headers: headers || {}
		}).done(function(res) {
			if (callback)
				callback(res)
		}).fail(function(xhr, status, err) {
			log("ajax request failed: " + JSON.stringify(status) + " status: " + xhr.status + " text: " + xhr.responseText)
			if (callback)
				callback({result: 0, error: { message: "ajax error"} })
			self.error(status)
		})
	}

	request(url, data, callback, type): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			log("UR11L : "  + url);
			self.requestImpl(url, data, function(res) {
				if (self.checkResponse(url, res, do_request))
					callback(res)
			}, type, {})
		}

		do_request()
	}

	onCompleted: {
		if (navigator.userAgent.indexOf('Android') >= 0 || navigator.userAgent.indexOf('iPhone') >= 0 || qml.core.vendor == 'samsung')
			this.baseUrl = "http://truba.tv:8080/api/";
		else
			this.baseUrl = "https://truba.tv:8080/api/";

		log("URL: " + this.baseUrl);
	}
}
