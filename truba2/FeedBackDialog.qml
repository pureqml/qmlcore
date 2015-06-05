Dialog {
	title: "Хотите улучшить сервис?";

	Row {
		anchors.centerIn: innerPanel;
		visible: parent.visible;
		spacing: 20;

		Input { id: emailInput; title: "Ваш Email"; }
		Input { id: messageInput; title: "Комментарий"; }
	}

	onAccepted: {
		var email = emailInput.value;
		var message = messageInput.value;
		if (message)
			this.protocol.sendEmail({
				email: email,
				message: message
			}, function() { log("Opinion send"); });
	}
}
