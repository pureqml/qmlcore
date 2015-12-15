Object {
	signal error;
	property bool loading: false;
	property string baseUrl;

	getProgramsAtDate(date, callback): {
		if (!date.getFullYear() || !date.getMonth() || !date.getDate())
			return;
		this.request("/programs/" + date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(), {}, callback)
	}

	getCurrentPrograms(callback): {
		this.request("/programs", {}, callback)
	}

	getChannels(callback): {
		var self = this
		self.loading = true
		this.request("/channels", {}, function(list) {
			callback(list)
			self.loading = false
		})
	}

	getProviders(callback): {
		this.request("/providers", {}, callback)
	}

	sendEmail(data, callback): {
		this.request("/feedback", data, callback, "POST")
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
			self.requestImpl(url, data, function(res) {
				if (res.error)
					log("Request failed: " + res.error.message);
				else
					callback(res)
			}, type, {})
		}

		do_request()
	}

	onCompleted: { this.baseUrl = "http://truba.tv/api/"; }
}
