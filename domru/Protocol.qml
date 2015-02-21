Object {
	property string baseUrl: "http://tv.domru.ru/api/";
	property string clientId : "er_ottweb_device";
	property string deviceId : "123";
	property string ssoSystem: "er";
	property string ssoKey;
	property string authToken;
	property string sessionId;
	property string username: "590014831333";
	property string password: "590014831333";
	property string region: "perm";
	property bool enabled;

	signal error;

	LocalStorage { id: authTokenStorage; name: "authToken"; }
	LocalStorage { id: sessionIdStorage; name: "sessionId"; }

	checkResponse(url, res): {
		if (!res.result) {
			console.log("failed response", url, JSON.stringify(res))
			if (res.error.message.indexOf("token") > -1)
				this.requestNewToken()
			this.error(res.error.message)
		}
	}

	request(url, data, callback, type, headers): {
		if (!this.enabled)
			return;
		console.log("request", url, data)
		var self = this;
		$.ajax({
			url: self.baseUrl + url,
			data: data,
			type: type || 'GET',
			headers: headers || {}
		}).done(function(res) {
			self.checkResponse(url, res)
			if (callback)
				callback(res)
		}).fail(function(req, status, err) {
			console.log(req, status, err)
			self.error(status)
		})
	}

	requestWithToken(url, data, callback, type, token): {
		if (!this.enabled)
			return;
		if (!token)
			token = this.authToken

		var self = this;
		if (!token)
		{
			console.log("no token, scheduling request " + url)
			if (!this._pending)
				this._pending = []

			this._pending.push(function(token) {
				self.request(url, data, callback, type, {'X-Auth-Token': token})
			})
			return
		}
		this.request(url, data, callback, type, {'X-Auth-Token': token})
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

	getAsset(id, callback): {
		this.requestWithToken("/collection/vod.asset/query/dimension/id/in/" + id, {}, function(res) {
			callback(res.collection[0])
		})
	}

	getUrl(assetId, streamId, callback): {
		this.requestWithToken("/resource/get_url/" + assetId + "/" + streamId + "?er_multiscreen_session_id=" + this.sessionId, {}, callback)
	}

	onAuthTokenChanged: {
		if (!this.authToken)
			return
		if (this._pending) {
			var self = this
			console.log("executing pending requests")
			this._pending.forEach(function(callback) { callback(self.authToken); })
		}
		this.requestWithToken("/er/multiscreen/status", {}, function(res) {console.log("multiscreen status", res); })
		//this.requestWithToken("/resource/get_url/48100", {}, function(res) {console.log("res", res); })
	}

	openSession: {
		this.requestWithToken('/er/multiscreen/ottweb/session/open/', {}, (function(res) {
			console.log("SESSION", res)
			this.sessionIdStorage.value = res.session_id
			this.sessionId = res.session_id
		}).bind(this), 'POST')
	}

	requestNewToken: {
		var self = this
		self.getToken(this.clientId, this.deviceId, this.region, function(res) {
			console.log("token", JSON.stringify(res))
			var authToken = res.token;
			self.login(self.username, self.password, self.region, function(res) {
				console.log("LOGIN", JSON.stringify(res));
				self.ssoKey = res.sso;
				self.getSubscriberDeviceToken(authToken, self.ssoSystem, self.ssoKey, function(res) {
					console.log("DEVICE TOKEN", JSON.stringify(res));
					self.authToken = res.token;
					self.authTokenStorage.value = res.token
					self.openSession()
				})
			})
		})
	}

	init: {
		if (sessionIdStorage.value && authTokenStorage.value) {
			this.sessionId = sessionIdStorage.value
			this.authToken = authTokenStorage.value
		} else if (authTokenStorage.value) {
			this.authToken = authTokenStorage.value;
			this.openSession()
		} else {
			this.requestNewToken()
		}
	}

	onCompleted: {
		authTokenStorage.read()
		sessionIdStorage.read()
		this.init()
	}
}
