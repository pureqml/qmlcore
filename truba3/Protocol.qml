Object {
	signal error;
	property string baseUrl: "http://truba.tv/api/";

	function getProgramsAtDate(date, callback) {
		if (!date.getFullYear() || !date.getMonth() || !date.getDate())
			return;
		this.request("/programs/" + date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(), {}, callback)
	}

	function getCurrentPrograms(callback) {
		this.request("/programs", {}, callback)
	}

	function getChannels(callback) {
		this.request("/channels", {}, callback)
	}

	function getProviders(callback) {
		this.request("/providers", {}, callback)
	}

	function requestImpl(url, data, callback, type, headers) {
		if (!this.enabled)
			return;
		if (url.charAt(0) === '/')
			url = url.slice(1)
		var self = this;

		var url = this.baseUrl + url
		if (data) {
			for (var name in data) {
				url += "&" + encodeURIComponent(name) + "=" + encodeURIComponent(data[name]);
			}
		}

		log("request", url, data)

		var req = new XMLHttpRequest();
		req.onreadystatechange = function() {
			if (req.readyState == XMLHttpRequest.DONE) {
				var res = JSON.parse(req.responseText);
				//log(req.responseText);
				if (!res.error) {
					callback(res);
				} else {
					log("Error during api call occured");
				}
			}
		}
		req.open("GET", url);
		req.send();
	}

	function request(url, data, callback, type) {
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
