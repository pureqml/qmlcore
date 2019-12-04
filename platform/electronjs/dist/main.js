const {app, BrowserWindow} = require('electron')
const path = require('path')

let win

function createWindow () {
	// Create the browser window.
	win = new BrowserWindow({
		width: {{ resolutionWidth | default(1280) }},
		height: {{ resolutionHeight | default(720) }},
		webPreferences: {
			preload: path.join(__dirname, 'preload.js')
		}
	})

	win.loadFile('index.html')

	// TODO: uncomment for debug
	// win.webContents.openDevTools()

	win.on('closed', function () { win = null })
}

app.on('ready', createWindow)

app.on('window-all-closed', function () {
	if (process.platform !== 'darwin') app.quit()
})

app.on('activate', function () {
	if (win === null)
		createWindow()
})
