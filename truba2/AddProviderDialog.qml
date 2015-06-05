Dialog {
	title: "Добавить провайдера";

	Row {
		anchors.centerIn: innerPanel;
		visible: parent.visible;
		spacing: 20;

		Input { id: emailInput; title: "Ваш Email"; }
		Input { id: providerInput; title: "Провайдер"; }
	}

	onAccepted: {
		var email = emailInput.value;
		var providerName = providerInput.value;
		if (providerName) {
			this.protocol.sendEmail({
				email: email,
				providerName: providerName
			}, function() { log("Provider send"); });
			this.stop();
		}
	}
}
