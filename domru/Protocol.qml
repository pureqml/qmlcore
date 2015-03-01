Object {
	property string baseUrl;
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
	property array originList;
	property array failedRequests;

	signal error;

	LocalStorage { id: authTokenStorage; name: "authToken"; }
	LocalStorage { id: sessionIdStorage; name: "sessionId"; }

	Timer {
		repeat: true;
		interval: 3000;
		running: true;
		onTriggered: {
			var reqs = this.parent.failedRequests
			this.parent.failedRequests = []
			var n = reqs.length
			if (n) {
				console.log("retrying " + n + " requests")
				for(var i = 0; i < n; ++i)
					reqs[i]()
			}
		}
	}

	checkResponse(url, res, request): {
		if (!res.result) {
			console.log("failed response " + url + " " + JSON.stringify(res))
			if (res.error.message.indexOf("token") > -1) {
				this.authToken = ""; //next responses will go to pending
				if (!this._pendingTokenRequests)
					this._pendingTokenRequests = []
				this._pendingTokenRequests.push(request)
				this.requestNewToken()
				return false
			}
			if (res.error.message === 'no entitlement' && res.error.reason === 'invalid er_multiscreen_session_id') {
				console.log("session expired")
				this.sessionId = ""
				if (!this._pendingSessionRequests)
					this._pendingSessionRequests = []
				this._pendingSessionRequests.push(request)
				this.openSession()
				return false
			}
			this.failedRequests.push(request)
			this.error(res.error.message)
			return false
		}
		return true
	}

	requestImpl(url, data, callback, type, headers): {
		if (!this.enabled)
			return;
		if (url.charAt(0) === '/')
			url = url.slice(1)
		console.log("request", url, data)
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
			console.log("ajax request failed: " + JSON.stringify(status) + " status: " + xhr.status + " text: " + xhr.responseText)
			if (callback)
				callback({result: 0, error: { message: "ajax error"} })
			self.error(status)
		})
	}

	getTokenHeader(token): {
		return {'X-Auth-Token': token}
	}

	request(url, data, callback, type): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url, data, function(res) {
				if (self.checkResponse(url, res, do_request))
					callback(res)
			}, type, {})
		}

		do_request()
	}

	requestWithToken(url, data, callback, type): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url, data, function(res) {
				if (self.checkResponse(url, res, do_request))
					callback(res)
			}, type, self.getTokenHeader(self.authToken))
		}

		if (self.authToken)
			do_request()
		else
		{
			console.log("no token, scheduling request " + url)

			if (!this._pendingTokenRequests)
				this._pendingTokenRequests = []
			this._pendingTokenRequests.push(do_request)
			return
		}
	}

	requestWithTokenAndSession(url, data, callback, type): {
		if (!this.enabled)
			return;

		var self = this;

		var do_request = function() {
			self.requestImpl(url + "?er_multiscreen_session_id=" + self.sessionId, data, function(res) {
				if (self.checkResponse(url, res, do_request))
					callback(res)
			}, type, self.getTokenHeader(self.authToken))
		}

		if (self.authToken && self.sessionId)
			do_request()
		else
		{
			console.log("no session or token, scheduling request " + url)

			if (!this._pendingSessionRequests)
				this._pendingSessionRequests = []
			this._pendingSessionRequests.push(do_request)
			return
		}
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

	getAssets(ids, callback): {
		this.requestWithToken("/collection/vod.asset/query/dimension/id/in/" + ids.join(','), {}, function(res) {
			callback(res.collection)
		})
	}

	getUrl(assetId, streamId, callback): {
		this.requestWithTokenAndSession("/resource/get_url/" + assetId + "/" + streamId, {}, callback)
	}

	getPrefix(query): {
		return query.indexOf('?') === -1 ? '?' : '&';
	}

	getChannelsWithSchedule(options, callback): {
		var query = '/epg/get_schedule/';
		if (options && options.startFrom)
			query += this.getPrefix(query) + 'start_from=' + options.startFrom;

		if (options && options.startTo)
			query += this.getPrefix(query) + 'start_to=' + options.startTo;

		if (options && options.select)
			query += this.getPrefix(query) + 'select=' + options.select;

		this.requestWithToken(query, {}, callback);
	}

	getEpgProgramByParams(epgChannelId, callback): {
		this.requestWithToken("/collection/epg.schedule/query/dimension/channel_id/in/" + epgChannelId, {}, callback);
	}

	resolveResource(res): {
		var grp = res.resource_group_id;
		var origin;
		this.originList.forEach(function(o) {
			if (o.resource_groups.indexOf(grp))
				origin = o
		})
		if (!origin)
			origin = this.originList[0]
		if (!origin)
			return

		return origin.url + "/public/r" + res.id
	}

	onAuthTokenChanged: {
		if (!this.authToken)
			return
		if (this._pendingTokenRequests) {
			console.log("executing pending requests(token)")
			this._pendingTokenRequests.forEach(function(callback) { callback(); })
		}
		//this.requestWithToken("/er/multiscreen/status", {}, function(res) {console.log("multiscreen status", res); })
		var self = this;
		this.requestWithToken('/resource/get_origin_list/', {}, function(res) { self.originList = res.origins; console.log("origins", self.originList) })
	}

	onSessionIdChanged: {
		if (!this.sessionId)
			return

		if (this._pendingSessionRequests) {
			console.log("executing pending requests(session)")
			this._pendingSessionRequests.forEach(function(callback) { callback(); })
		}
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
		if (navigator.userAgent.indexOf('Android') >= 0 || navigator.userAgent.indexOf('iPhone') >= 0 || qml.core.vendor == 'samsung')
			this.baseUrl = "http://tv.domru.ru/api/" //it seems https returns status 0 as cross-site reponse
		else
			this.baseUrl = "https://tv.domru.ru/api/"

		authTokenStorage.read()
		sessionIdStorage.read()
		this.init()
	}
}
