var assert = require('assert')
var sinon = require('sinon')
var Model = require('./model.js')
var View = require('./view.js')

describe('ModelUpdate', function() {
	describe('untouched model', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			mock.expects('_insertItems').once().withArgs(0, 6000)
			model.reset(6000)
			view.length(6000)
			model.apply(view)
		})
	})

	describe('sequental left insert', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			mock.expects('_insertItems').once().withArgs(0, 10)
			for(var i = 0; i < 10; ++i)
				model.insert(0, 1)
			view.length(10)
			model.apply(view)
		})
	})

	describe('sequental right insert', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			mock.expects('_insertItems').once().withArgs(0, 10)
			for(var i = 0; i < 10; ++i)
				model.insert(i, i + 1)
			view.length(10)
			model.apply(view)
		})
	})

	describe('sequental left remove', function() {
		it('should set single remove range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			model.reset(10)
			model.apply(view)

			mock.expects('_removeItems').once().withArgs(0, 10)
			for(var i = 0; i < 10; ++i)
				model.remove(0, 1)
			view.length(0)
			model.apply(view)
		})
	})

	describe('sequental right remove', function() {
		it('should set single remove range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			model.reset(10)
			model.apply(view)

			mock.expects('_removeItems').once().withArgs(0, 10)
			for(var i = 9; i >= 0; --i)
				model.remove(i, i + 1)
			view.length(0)
			model.apply(view)
		})
	})

	describe('sequental left update', function() {
		it('should set single remove range', function() {
			model = new Model()
			view = new View()
			mock = sinon.mock(view)
			model.reset(5)
			model.apply(view)

			mock.expects('_updateDelegate').once().withArgs(0, 10)
			for(var i = 1; i < 3; ++i)
				model.update(i, i + 1)
			model.apply(view)
		})
	})
})
