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
		var provider = providerInput.value;
		if (provider) {
			this.protocol.sendEmail({
				email: email,
				provider: provider
			}, function() { log("Provider send"); });
			this.stop();
		}
	}
}
