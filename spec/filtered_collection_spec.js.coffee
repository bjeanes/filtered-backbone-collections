# = require jquery
# = require underscore
# = require backbone
# = require backbone/ext/filtered_collection

describe 'Backbone.Collection#subset', ->
  beforeEach ->
    @Model            = Backbone.Model
    @ParentCollection = Backbone.Collection.extend
      model: @Model
      initialize: (models, @options) ->

    @parentCollection = new @ParentCollection [
      { id: 1, color: "red",    status: 'started'     },
      { id: 2, color: "blue",   status: 'in-progress' },
      { id: 3, color: "blue",   status: 'in-progress' },
      { id: 4, color: "yellow", status: 'in-progress' },
      { id: 5, color: "green",  status: 'finished'    },
    ], @options = {some: "options"}

    @addMatchers
      toContainModel: (expected) -> @actual.contains(expected)

  context "with no filter function", ->
    beforeEach ->
      @childCollection = @parentCollection.subset()

    it "has all of the parent's models", ->
      expect(@childCollection.models).toEqual(@parentCollection.models)

    context 'when adding to the parent collection', ->
      beforeEach -> @model = new @Model({id: Date.now(), status: "new"})

      it "adds the model", ->
        @parentCollection.add(@model)
        expect(@childCollection).toContainModel(@model)

      it "triggers a collection add event", ->
        handler = jasmine.createSpy()
        @childCollection.bind 'add', handler
        @parentCollection.add(@model)
        expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

      it "triggers a model add event for each collection", ->
        handler = jasmine.createSpy()
        @model.bind 'add', handler
        @parentCollection.add(@model)

        expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))
        expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

    context 'when removing from the parent collection', ->
      beforeEach -> @model = @parentCollection.at(0)

      it "removes the model", ->
        @parentCollection.remove(@model)
        expect(@childCollection).not.toContainModel(@model)

      it "triggers a collection remove event", ->
        handler = jasmine.createSpy()
        @childCollection.bind 'remove', handler
        @parentCollection.remove(@model)
        expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

      it "triggers a model remove event for each collection", ->
        handler = jasmine.createSpy()
        @model.bind 'remove', handler
        @parentCollection.remove(@model)

        expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))
        expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

  context 'with a filter function', ->
    beforeEach ->
      @childCollection = @parentCollection.subset (m) ->
        m.get('status') == 'in-progress'

    it "calls the initializer with the same options passed to the parent's constructor", ->
      expect(@childCollection.options).toBe(@options)

    it "has a subset of the parent's models", ->
      expect(@childCollection.length).toBeLessThan(@parentCollection.length)

    it "has the matching elements", ->
      expect(@childCollection).toContainModel(@parentCollection.get(2))

    it "does not have the non-matching elements", ->
      expect(@childCollection).not.toContainModel(@parentCollection.get(1))
      expect(@childCollection).not.toContainModel(@parentCollection.get(5))

    it "maintains its own index", ->
      expect(@childCollection.at(0)).toBe(@parentCollection.at(1))
      expect(@childCollection.at(1)).toBe(@parentCollection.at(2))
      expect(@childCollection.at(2)).toBe(@parentCollection.at(3))

    context 'when adding to the parent collection', ->
      context "and the model matches the filter", ->
        beforeEach -> @model = new @Model({id: Date.now(), status: "in-progress"})

        it "adds the model", ->
          @parentCollection.add(@model)
          expect(@childCollection).toContainModel(@model)

        it "triggers a collection add event", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'add', handler
          @parentCollection.add(@model)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "triggers a model add event for each collection", ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          @parentCollection.add(@model)

          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

      context "and the model does not match the filter", ->
        beforeEach -> @model = new @Model({id: Date.now(), status: "new"})

        it "does not add the model", ->
          @parentCollection.add(@model)
          expect(@childCollection).not.toContainModel(@model)

        it "does not trigger a collection add event", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).not.toHaveBeenCalled()

        it "does not trigger a model add event on the filtered collection", ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          @parentCollection.add(@model)

          expect(handler).not.toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "triggers a model add event on the parent collection", ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          @parentCollection.add(@model)

          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

    context "when removing a model from the parent collection", ->
      context "when the model matches the filter (i.e. is in the child collection)", ->
        beforeEach -> @model = @parentCollection.at(1)

        it "removes the model", ->
          @parentCollection.remove(@model)
          expect(@childCollection).not.toContainModel(@model)

        it "triggers a collection remove event for the child collection", ->
          handler = jasmine.createSpy()
          @parentCollection.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

        it "triggers a collection remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "triggers a model remove event for the child collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "triggers a model remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

      context "when the model does not match the filter (i.e. is not in the child collection)", ->
        beforeEach -> @model = @parentCollection.at(0)

        it "triggers a model remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

        it "triggers a collection remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @parentCollection.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

        it "does not trigger a model remove event for the child collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).not.toHaveBeenCalledWith(@model, @childCollection , jasmine.any(Object))

        it "does not trigger a collection remove event for the child collection", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'remove', handler
          @parentCollection.remove(@model)
          expect(handler).not.toHaveBeenCalled()

    context "when changing a model", ->
      context "so that it becomes matched when currently unmatched", ->
        beforeEach -> @model = @parentCollection.at(0)
        changeModel = -> @model.set status: 'in-progress'

        it "is adds the model", ->
          expect(@childCollection).not.toContainModel(@model)
          changeModel.call(@)
          expect(@childCollection).toContainModel(@model)

        it "triggers a collection add event for the child collection", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'add', handler
          changeModel.call(@)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "does not trigger a collection add event for the parent collection", ->
          handler = jasmine.createSpy()
          @parentCollection.bind 'add', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalled()

        it "triggers a model add event for the child collection", ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          changeModel.call(@)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "does not trigger a model add event for the parent collection", ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

      context "so that it becomes unmatched when currently matched", ->
        beforeEach -> @model = @parentCollection.at(1)
        changeModel = -> @model.set status: 'invaalid'

        it "removes the model", ->
          expect(@childCollection).toContainModel(@model)
          changeModel.call(@)
          expect(@childCollection).not.toContainModel(@model)

        it "triggers a collection remove event for the child collection", ->
          handler = jasmine.createSpy()
          @childCollection.bind 'remove', handler
          changeModel.call(@)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "does not trigger a collection remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @parentCollection.bind 'remove', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalled()

        it "triggers a model remove event for the child collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          changeModel.call(@)
          expect(handler).toHaveBeenCalledWith(@model, @childCollection, jasmine.any(Object))

        it "does not trigger a model remove event for the parent collection", ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalledWith(@model, @parentCollection, jasmine.any(Object))

      context "so that it remains matched", ->
        beforeEach -> @model = @parentCollection.at(1)
        changeModel = -> @model.set color: 'red'

        it 'still has the model', ->
          expect(@childCollection).toContainModel(@model)
          changeModel.call(@)
          expect(@childCollection).toContainModel(@model)

        it 'does not fire any remove event', ->
          handler = jasmine.createSpy()
          @model.bind 'remove', handler
          @childCollection.bind 'remove', handler
          @parentCollection.bind 'remove', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalled()

      context "so that it remains unmatched", ->
        beforeEach -> @model = @parentCollection.at(0)
        changeModel = -> @model.set color: 'red'

        it 'still does not have the model', ->
          expect(@childCollection).not.toContainModel(@model)
          changeModel.call(@)
          expect(@childCollection).not.toContainModel(@model)

        it 'does not fire any add event', ->
          handler = jasmine.createSpy()
          @model.bind 'add', handler
          @childCollection.bind 'add', handler
          @parentCollection.bind 'add', handler
          changeModel.call(@)
          expect(handler).not.toHaveBeenCalled()

    context "when adding a model directly to child collection", ->     # FIXME: undefined behavior?

    context "when removing a model directly from child collection", -> # FIXME: undefined behavior?

    describe 'a second level filtered collection', ->
      beforeEach ->
        @grandchildCollection = @childCollection.subset (m) -> m.get("color") == "blue"

      it "has a subset of its parent's models", ->
        expect(@grandchildCollection.length).toBeLessThan(@childCollection.length)


  # TODO: is this possible?
  it "has a class name that identifies what it is filtering"

  # TODO: changing subset filter function reapplies filter and should trigger appropriate events
