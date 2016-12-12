var assert = require('assert')
var sinon = require('sinon')
var Model = require('./model.js')
var View = require('./view.js')

describe('ModelUpdate', function() {
	describe('reset model', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_insertItems')
			model.reset(6000)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 0, 6000)
		})
	})

	describe('sequental left insert', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_insertItems')
			for(var i = 0; i < 10; ++i)
				model.insert(0, 1)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 0, 10)
		})
	})

	describe('sequental right insert', function() {
		it('should set single insert range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_insertItems')
			for(var i = 0; i < 10; ++i)
				model.insert(i, i + 1)
			model.apply(view)
			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 0, 10)
		})
	})

	describe('sequental left remove', function() {
		it('should set single remove range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_removeItems')

			model.reset(10)
			model.apply(view)

			for(var i = 0; i < 10; ++i)
				model.remove(0, 1)
			model.apply(view)
			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 0, 10)
		})
	})

	describe('sequental right remove', function() {
		it('should set single remove range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_removeItems')

			model.reset(10)
			model.apply(view)

			for(var i = 9; i >= 0; --i)
				model.remove(i, i + 1)
			model.apply(view)
			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 0, 10)
		})
	})

	describe('sequental left update', function() {
		it('should set three ranges, noop, update, noop', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_updateItems')

			model.reset(5)
			model.apply(view)

			for(var i = 1; i <= 3; ++i)
				model.update(i, i + 1)
			model.apply(view)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 1, 4)
		})
	})

	describe('sequental right update', function() {
		it('should set three ranges, noop, update, noop', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_updateItems')

			model.reset(5)
			model.apply(view)

			for(var i = 3; i >= 1; --i)
				model.update(i, i + 1)
			model.apply(view)

			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 1, 4)
		})
	})

	describe('interlaced update', function() {
		it('should set single-value ranges, noop, update, noop', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_updateItems')

			model.reset(10)
			model.apply(view)

			for(var i = 1; i < 10; i += 2)
				model.update(i, i + 1)
			model.apply(view)

			sinon.assert.callCount(view._updateItems, 5)
			sinon.assert.calledWith(view._updateItems, 1, 2)
			sinon.assert.calledWith(view._updateItems, 3, 4)
			sinon.assert.calledWith(view._updateItems, 5, 6)
			sinon.assert.calledWith(view._updateItems, 7, 8)
			sinon.assert.calledWith(view._updateItems, 9, 10)
		})
	})

	describe('interlaced full update', function() {
		it('should set single range', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_updateItems')

			model.reset(10)
			model.apply(view)

			for(var i = 1; i < 10; i += 2)
				model.update(i, i + 1)
			for(var i = 0; i < 9; i += 2)
				model.update(i, i + 1)
			model.apply(view)

			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
		})
	})

	describe('reset model, the same row count', function() {
		it('should call insert, then update', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_updateItems')
			sinon.spy(view, '_removeItems')
			model.reset(10)
			model.apply(view)
			model.reset(10)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 0, 10)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
			assert(!view._removeItems.called)
		})
	})

	describe('reset model, with bigger row count', function() {
		it('should call insert, update, and insert', function() {
			model = new Model()
			view = new View()
			var insert = sinon.spy(view, '_insertItems')
			var update = sinon.spy(view, '_updateItems')
			var remove = sinon.spy(view, '_removeItems')
			//fixme: add withArgs here

			model.reset(10)
			model.apply(view)
			model.reset(20)
			model.apply(view)

			sinon.assert.calledTwice(view._insertItems)
			sinon.assert.calledOnce(view._updateItems)
			assert(!view._removeItems.called)
		})
	})

	describe('reset model, with lesser row count', function() {
		it('should call insert, update, and remove', function() {
			model = new Model()
			view = new View()

			var insert = sinon.spy(view, '_insertItems')
			var update = sinon.spy(view, '_updateItems')
			var remove = sinon.spy(view, '_removeItems')
			//fixme: add withArgs here

			model.reset(20)
			model.apply(view)
			model.reset(10)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledOnce(view._removeItems)
		})
	})
})
