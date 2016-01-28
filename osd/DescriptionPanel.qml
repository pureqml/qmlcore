Item {
	id: panelProto;
	property variant item;
	signal play;
	anchors.fill: renderer;
	visible: false;
	focus: true;

	Rectangle {
		anchors.fill: parent;
		color: octoColors.panelColor;
		opacity: 0.3;
	}

	Rectangle {
		id: descripationBackground;
		width: height + 500;
		height: descriptionPoster.height;
		color: octoColors.panelColor;
		x: descriptionPoster.x;
		y: descriptionPoster.y;
		effects.shadow.blur: 10;
		effects.shadow.color: "#000";
		effects.shadow.spread: 5;
	}

	Image {
		id: descriptionPoster;
		width: height / 3 * 2;
		fillMode: Image.Stretch;

		Behavior on height { Animation { id: imageHeightAnim; duration: 250; } }
		Behavior on x { Animation { id: imageXAnim; duration: 250; } }
		Behavior on y { Animation { id: imageYAnim; duration: 250; } }
	}

	Item {
		anchors.top: descriptionPoster.top;
		anchors.left: descriptionPoster.right;
		anchors.right: descripationBackground.right;
		anchors.bottom: descriptionPoster.bottom;
		anchors.margins: 10;
		opacity: activeFocus ? 1.0 : 0.0;
		clip: true;

		Item {
			width: 640;
			height: 400;
			anchors.top: parent.top;
			anchors.left: parent.left;

			BigText {
				id: descriptionTitle;
				anchors.top: parent.top;
				anchors.left: parent.left;
				color: octoColors.textColor;
			}

			MainText {
				id: descriptionYear;
				anchors.left: descriptionTitle.right;
				anchors.right: parent.right;
				anchors.bottom: descriptionTitle.bottom;
				anchors.leftMargin: 10;
				anchors.bottomMargin: 3;
				color: octoColors.subTextColor;
			}

			SmallText {
				id: descriptionSlogan;
				anchors.top: descriptionTitle.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				color: octoColors.subTextColor;
			}

			Column {
				id: shortInfoLayout;
				anchors.top: descriptionSlogan.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.topMargin: 10;

				SmallText {
					id: descriptionGenres;
					color: octoColors.textColor;
				}

				SmallText {
					id: descriptionDirector;
					color: octoColors.textColor;
				}

				SmallText {
					id: descriptionDuration;
					color: octoColors.textColor;
				}

				Item {
					height: imdbIcon.paintedHeight;

					Image {
						id: imdbIcon;
						source: "res/octoosd/imdb.png";
					}

					SmallText {
						id: descriptionRating;
						anchors.left: imdbIcon.right;
						anchors.verticalCenter: imdbIcon.verticalCenter;
						anchors.leftMargin: 10;
						color: octoColors.textColor;
					}
				}
			}

			SmallText {
				id: descriptionText;
				anchors.top: shortInfoLayout.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.topMargin: 20;
				color: octoColors.textColor;
				wrap: true;
			}
		}

		OctoButton {
			id: playButton;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			text: "Play";

			onSelectPressed: {
				panelProto.play(panelProto.item)
				panelProto.visible = false
			}
		}

		Behavior on opacity { Animation { duration: 300; } }
	}

	show(item): {
		this.visible = true
		this.item = item
		playButton.setFocus()

		descriptionPoster.x = item.x
		imageXAnim.complete()
		descriptionPoster.y = item.y
		imageYAnim.complete()
		descriptionPoster.source = item.icon
		descriptionPoster.height = item.height
		imageHeightAnim.complete()

		descriptionPoster.height += 180
		descriptionPoster.x = (renderer.width - 980) / 2
		descriptionPoster.y = (renderer.height - 480) / 2

		var info = item.movieInfo
		descriptionTitle.text = info.title
		descriptionSlogan.text = info.slogan
		descriptionText.text = info.description
		descriptionYear.text = info.year.toString()
		descriptionDirector.text = "Director: " + info.director
		descriptionDuration.text = info.duration.toString() + " min"
		descriptionRating.text = info.rating.imdb.toString()
		descriptionGenres.text = "Genres: " + info.genre[0]

		for (var i = 1; i < info.genre.length; ++i)
			descriptionGenres.text += ", " + info.genre[i]
	}
}
