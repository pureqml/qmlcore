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

	describe('insert + remove', function() {
		it('should result in no', function() {
			model = new Model()
			view = new View()
			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_updateItems')
			sinon.spy(view, '_removeItems')
			model.insert(0, 10)
			model.remove(0, 10)
			model.apply(view)

			sinon.assert.notCalled(view._insertItems)
			sinon.assert.notCalled(view._updateItems)
			sinon.assert.notCalled(view._removeItems)
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

	describe('stray update', function() {
		it('should call update', function() {
			model = new Model()
			view = new View()

			model.reset(5)
			model.apply(view)

			sinon.spy(view, '_updateItems')
			model.update(0, 1)
			model.apply(view)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 1)
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

	describe('reset model, then update', function() {
		it('should call insert, update, and remove', function() {
			model = new Model()
			view = new View()

			var insert = sinon.spy(view, '_insertItems')
			var update = sinon.spy(view, '_updateItems')
			var remove = sinon.spy(view, '_removeItems')

			model.reset(20)
			model.apply(view)

			sinon.assert.calledWith(view._insertItems, 0, 20)
			sinon.assert.notCalled(view._updateItems)
			sinon.assert.notCalled(view._removeItems)

			model.reset(20)
			model.update(0, 1)
			model.apply(view)

			sinon.assert.calledWith(view._insertItems, 0, 20)
			sinon.assert.callCount(view._insertItems, 1)
			sinon.assert.calledWith(view._updateItems, 0, 20)
			sinon.assert.callCount(view._updateItems, 1)
			sinon.assert.notCalled(view._removeItems)
		})
	})

	describe('insert + update', function() {
		it('should call insert and update with no overlap', function() {
			model = new Model()
			view = new View()

			model.reset(10)
			model.apply(view)

			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_updateItems')

			model.insert(10, 20)
			for(var i = 0; i < 20; ++i)
				model.update(i, i + 1)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 10, 20)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
		})
	})

	describe('update + remove', function() {
		it('should call remove and update with no overlap', function() {
			model = new Model()
			view = new View()

			model.reset(20)
			model.apply(view)

			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			for(var i = 0; i < 20; ++i)
				model.update(i, i + 1)
			model.remove(10, 20)
			model.apply(view)

			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 10, 20)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
		})
	})

	describe('remove + update', function() {
		it('should call remove and update with no overlap', function() {
			model = new Model()
			view = new View()

			model.reset(20)
			model.apply(view)

			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			model.remove(0, 10)
			for(var i = 0; i < 10; ++i)
				model.update(i, i + 1)
			model.apply(view)

			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 0, 10)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
		})
	})

	describe('remove from front + insert to back', function() {
		it('should call to remove/update/insert because it changes model.index', function() {
			model = new Model()
			view = new View()

			model.reset(10)
			model.apply(view)

			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			model.remove(0, 1)
			model.insert(9, 10)
			model.apply(view)

			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 0, 1)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 9)
			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 9, 10)
		})
	})

	describe('insert to front + remove from back', function() {
		it('should call to remove/update/insert because it changes model.index', function() {
			model = new Model()
			view = new View()

			model.reset(10)
			model.apply(view)

			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			model.insert(0, 1)
			model.remove(10, 11)
			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 0, 1)
			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 1, 10)
			sinon.assert.calledOnce(view._removeItems)
			sinon.assert.calledWith(view._removeItems, 10, 11)
		})
	})

	describe('reset + insert same row count', function() {
		it('should call to update', function() {
			model = new Model()
			view = new View()

			model.reset(10)
			model.apply(view)

			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			model.reset(0)
			for(var i = 0; i < 10; ++i)
				model.insert(i, i + 1)
			model.apply(view)

			sinon.assert.calledOnce(view._updateItems)
			sinon.assert.calledWith(view._updateItems, 0, 10)
			sinon.assert.notCalled(view._insertItems)
			sinon.assert.notCalled(view._removeItems)
		})
	})

	describe('reset + insert + reset + insert', function() {
		it('should call update/insert once', function() {
			model = new Model()
			view = new View()

			model.reset(4)
			model.apply(view)

			model.reset(0)
			model.reset(0)
			model.insert(0, 5)

			model.reset(0)
			model.reset(0)
			model.insert(0, 6)

			model.reset(0)
			model.reset(0)
			model.insert(0, 8)

			sinon.spy(view, '_insertItems')
			sinon.spy(view, '_removeItems')
			sinon.spy(view, '_updateItems')

			model.apply(view)

			sinon.assert.calledOnce(view._insertItems)
			sinon.assert.calledWith(view._insertItems, 4, 8)
			sinon.assert.notCalled(view._removeItems)
			sinon.assert.callCount(view._updateItems, 1)
			sinon.assert.calledWith(view._updateItems, 0, 4)
		})
	})
})
