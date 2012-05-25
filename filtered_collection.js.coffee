select = (items, fn) ->
  items = if _.isArray(items) then items else [items]
  _(items).select(fn)

reject = (items, fn) -> select(items, -> !fn.apply(@, arguments))

subsetFor = (superset, filter) ->
  reset = (collection) -> @reset(filter.fn(collection.models))

  change = (model) ->
    matches = filter.fn(model)

    if matches && !@contains(model)
      @add(model)
      return

    if !matches && @contains(model)
      @remove(model)
      return

  class Subset extends superset.constructor
    constructor: ->
      @__defineSetter__? "subsetFilter", @setSubsetFilter

      @bind 'filter', @applySubsetFilter
      superset.bind 'add',    @add, @
      superset.bind 'remove', @remove, @
      superset.bind 'reset',  reset, @
      superset.bind 'change', change, @

      super

    setSubsetFilter: (fn) =>
      filter.fn = fn
      @trigger('filter')

    applySubsetFilter: =>
      superset.each (model) =>
        if filter.fn(model)
          @add(model)
        else
          @remove(model)

    add: (models, options) ->
      models = select models, (model) -> superset.contains(model) && filter.fn(model)
      super(models, options)

    remove: (models, options) ->
      models = reject models, (model) -> superset.contains(model) && filter.fn(model)
      super(models, options)

Backbone.Collection.prototype.subset = (fn) ->
  filter = { fn: fn || -> true }
  Subset = subsetFor(@, filter)
  new Subset(@filter(filter.fn), @options)

# Replace Backbone.Collection with a version that stores the passed
# in options so that we can restore them in the subset classes
class Backbone.Collection extends Backbone.Collection
  constructor: (models, @options) -> super(models, @options)

