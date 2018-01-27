var body = document.body
var progressBar = document.createElement('div')
progressBar.style.position = 'fixed'
progressBar.style.height = '4px'
progressBar.style.backgroundColor = '#B71C1C'
body.append(progressBar)

_globals.core.core.onProgress = function(current, total) {
	//log(current, total)
	if (current < total) {
		var bw = body.clientWidth, bh = window.innerHeight
		var w = current / total * bw
		progressBar.style.left = bw / 2 - w / 2 + 'px'
		progressBar.style.width = w + 'px'
		progressBar.style.top = window.innerHeight * 0.9 + 'px'
		progressBar.style.display = 'block'
		progressBar.offsetHeight
	} else
		progressBar.style.display = 'none'
}
