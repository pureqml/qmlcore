Object {
	property string baseUrl: "http://tv.domru.ru/api/";
	property string clientId : "er_ottweb_device";
	property string deviceId : "123";
	property string ssoSystem: "er";
	property string ssoKey;
	property string authToken;
	property string username: "590014831333";
	property string password: "590014831333";
	property string region: "perm";

	signal error;

	checkResponse(res): {
		if (res.result)
			return true;
		else {
			console.log("failed response", JSON.stringify(res))
			this.error(res.error.message)
		}
	}

	request(url, data, callback, type, headers): {
		console.log("request", url, data)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: data,
			type: type || 'GET',
			headers: headers || {}
		}).done(function(res) {
			if (self.checkResponse(res) && callback)
				callback(res)
		}).fail(function(req, status, err) {
			console.log(req, status, err)
			self.error(status)
		})
	}

	requestWithToken(url, data, callback, type): {
		if (!this.authToken)
		{
			console.log("no token, scheduling request")
			if (!this._pending)
				this._pending = []

			var self = this;
			this._pending.push(function() {
				self.request(url, data, callback, type, {'X-Auth-Token': self.authToken})
			})
		}
		this.request(url, data, callback, type, {'X-Auth-Token': this.authToken})
	}

	getToken(clientId, deviceId, region, callback): {
		var data = {
			client_id: clientId,
			timestamp: (new Date()).getTime(),
			device_id: deviceId,
			er_region: region
		}
		this.request("/token/device", data, callback);
	}

	login(username, password, region, callback): {
		this.request("/er/ssoauth/auth", {username: username, password: password, region: region}, callback, 'POST')
	}

	getRegionList(callback): {
		this.requestWithToken("/er/misc/domains/", {}, callback);
	}

	getSubscriberDeviceToken(authToken, ssoSystem, ssoKey, callback): {
		this.request("/token/subscriber_device/by_sso", {sso_system: ssoSystem, auth_token: authToken, sso_key: ssoKey}, callback)
	}

	getChannelList(callback): {
		this.requestWithToken("/channel_list/lists", {}, callback)
	}

	onAuthTokenChanged: {
		if (this._pending) {
			console.log("executing pending requests")
			this._pending.forEach(function(callback) { callback(); })
		}
	}

	onCompleted: {
		var self = this;
		self.getToken(this.clientId, this.deviceId, self.region, function(res) {
			console.log("token", JSON.stringify(res))
			var authToken = res.token;
			self.login(self.username, self.password, self.region, function(res) {
				console.log("LOGIN", JSON.stringify(res));
				self.ssoKey = res.sso;
				self.getSubscriberDeviceToken(authToken, self.ssoSystem, self.ssoKey, function(res) {
					console.log("DEVICE TOKEN", JSON.stringify(res));
					self.authToken = res.token;
				})
			})
		})
	}
}
