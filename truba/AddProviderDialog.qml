Dialog {
	title: "Добавить провайдера";

	Column {
		anchors.centerIn: innerPanel;
		visible: parent.visible;
		spacing: 20;

		Row {
			spacing: 10;

			Input { id: emailInput; title: "Ваш Email"; }

			Text {
				width: 0;
				text: "Необязательно";
				anchors.verticalCenter: emailInput.innerTextInput.verticalCenter;
				font.italic: true;
				font.pixelSize: 20;
				color: colorTheme.disabledTextColor;
			}
		}

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
