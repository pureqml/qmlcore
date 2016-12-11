var assert = require('assert')
var sinon = require('sinon')
var Model = require('./model.js')
var View = require('./view.js')

describe('ModelUpdate', function() {
	describe('empty', function() {
		it('should contain single noupdate range', function() {
			model = new Model()
			view = sinon.mock(new View())
			view.expects('_insertItems').once().withArgs(0, 6000)
			model.reset(6000)
			model.apply(view)
		})
	})
})
