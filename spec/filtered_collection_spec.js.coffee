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
  it "has a class name that identifies what it is filtering", ->

  context "when a filter event triggered on an existing subset, and a model in the subset does not match the current filter", ->
    beforeEach ->
      filterStatus = 'in-progress'

      filter = (m) ->
        m.get('status') == filterStatus

      @childCollection = @parentCollection.subset(filter)

      @inProgressModel = @parentCollection.get(2)
      expect(@childCollection).toContainModel(@inProgressModel)

      @modelHandler = jasmine.createSpy()
      @inProgressModel.bind('remove', @modelHandler)

      @collectionHandler = jasmine.createSpy()
      @childCollection.bind('remove', @collectionHandler)
      @parentCollection.bind('remove', @collectionHandler)

      filterStatus = 'finished'
      @childCollection.trigger("filter")

      it "should not contain the non-matching model", ->
        expect(@childCollection).not.toContainModel(@inProgressModel)

      it "triggers a collection remove event on the subset collection", ->
        expect(@collectionHandler).toHaveBeenCalledWith(@inProgressModel, @childCollection, jasmine.any(Object))

      it "triggers a model remove event on the model with the subset collection", ->
        expect(@modelHandler).toHaveBeenCalledWith(@inProgressModel, @childCollection, jasmine.any(Object))

      it "does not trigger a collection remove event on the parent collection", ->
        expect(@collectionHandler).not.toHaveBeenCalledWith(@inProgressModel, @parentCollection, jasmine.any(Object))

      it "does not trigger a model remove event on the model with the parent collection", ->
        expect(@modelHandler).not.toHaveBeenCalledWith(@inProgressModel, @parentCollection, jasmine.any(Object))

  context "when a filter event triggered on a subset of a subset, and a model in the (grandchild) subset does not match the current filter, but still matches the parent's filter", ->
    beforeEach ->
      filterColor = "yellow"

      grandChildFilter = (m) ->
        m.get('color') == filterColor

      @childCollection = @parentCollection.subset((m) -> m.get('status') == "in-progress")
      @grandchildCollection = @childCollection.subset(grandChildFilter)

      @yellowModel = @parentCollection.get(4)
      expect(@grandchildCollection).toContainModel(@yellowModel)

      @modelHandler = jasmine.createSpy()
      @yellowModel.bind('remove', @modelHandler)

      @collectionHandler = jasmine.createSpy()
      @grandchildCollection.bind('remove', @collectionHandler)
      @childCollection.bind('remove', @collectionHandler)
      @parentCollection.bind('remove', @collectionHandler)

      filterColor = 'blue'
      @grandchildCollection.trigger("filter")

    it "should no longer contain the non-matching model", ->
      expect(@grandchildCollection).not.toContainModel(@yellowModel)

    it "triggers a collection remove event on the grandchild collection", ->
      expect(@collectionHandler).toHaveBeenCalledWith(@yellowModel, @grandchildCollection, jasmine.any(Object))

    it "triggers a model remove event on the model with the grandchild collection", ->
      expect(@modelHandler).toHaveBeenCalledWith(@yellowModel, @grandchildCollection, jasmine.any(Object))

    it "does not trigger a collection remove event on the parent or the child collection", ->
      expect(@collectionHandler).not.toHaveBeenCalledWith(@yellowModel, @parentCollection, jasmine.any(Object))
      expect(@collectionHandler).not.toHaveBeenCalledWith(@yellowModel, @childCollection, jasmine.any(Object))

    it "does not trigger a model remove event on the model with the parent or the child collection", ->
      expect(@modelHandler).not.toHaveBeenCalledWith(@yellowModel, @parentCollection, jasmine.any(Object))
      expect(@modelHandler).not.toHaveBeenCalledWith(@yellowModel, @childCollection, jasmine.any(Object))
