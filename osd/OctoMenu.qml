Item {
	id: octoMenuProto;
	signal itemFocused;
	signal itemSelected;
	property bool showed: true;
	focus: showed;
	visible: showed;

	ListModel { id: menuModel; }

	ListModel { id: menuDelegateModel; }

	ListView {
		id: innerMenuView;
		anchors.fill: parent;
		keyNavigationWraps: false;
		positionMode: ListView.Center;
		model: menuModel;
		hoverEnabled: true;
		delegate: MenuDelegate {
			onItemFocused(item): {
				octoMenuProto.itemFocused(item)
			}

			onItemSelected(item): {
				var itemBox = innerMenuView.getItemPosition(innerMenuView.currentIndex)
				item.x += octoMenuProto.x + innerMenuView.x
				item.y += octoMenuProto.y + innerMenuView.y + itemBox[1] - innerMenuView.contentY
				octoMenuProto.itemSelected(item)
			}
		}
	}

	fill(data): {
		if (!data || !data.root) {
			log("Can't read data from file.")
			return
		}

		menuModel.reset();
		for (var i in data.root) {
			var target = data.root[i].target
			menuModel.append({ "text": data.root[i].text, "content": data[target] })
		}
	}

	show: {
		this.showed = true
		innerMenuView.setFocus()
	}

	hide: { this.showed = false }
}
