Object {
	property string baseUrl: "http://tv.domru.ru/api/";
	property string clientId;
	property string deviceId;
	property string ssoSystem;

	signal error;

	checkResponse(res): {
		if (res.result)
			return true;
		else {
			console.log("failed response", JSON.stringify(res))
			this.error(res.error.message)
		}
	}

	request(url, data, callback, type): {
		console.log("request", url, data)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: data,
			success: function(res) {
				if (self.checkResponse(res) && callback)
					callback(res)
			},
			type: type || 'GET'
		});
	}

	getToken(clientId, deviceId, callback): {
		var data = {
			client_id: clientId,
			timestamp: (new Date()).getTime(),
			device_id: deviceId
		}
		this.request("/token/device", data, callback);
	}

	login(username, password, region, callback): {
		this.request("/er/ssoauth/auth", {username: username, password: password, region: region}, callback, 'POST')
	}

	getRegionList(callback): {
		this.request("/er/misc/domains/", {}, callback);
	}
}
