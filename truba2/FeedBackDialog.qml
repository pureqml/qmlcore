Dialog {
	title: "Хотите улучшить сервис?";

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

		InputTextArea { id: messageInput; title: "Комментарий"; }
	}

	onAccepted: {
		var email = emailInput.value;
		var message = messageInput.value;
		if (message) {
			this.protocol.sendEmail({
				email: email,
				message: message
			}, function() { log("Opinion send"); });
			this.stop();
		}
	}
}
