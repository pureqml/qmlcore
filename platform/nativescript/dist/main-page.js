const qml = require('./qml.main.js')
const Page = require('ui/page').Page

function onNavigatingTo(args) {
	const page = args.object
	page.on(Page.navigatedToEvent, (args) => {
		var ctx = qml.run(page)
		ctx.backend.finalize()
	})
}

exports.onNavigatingTo = onNavigatingTo
