defaultFilter = -> true
toArray       = (items) -> _(if _.isArray(items) then items else [items])

subsetFor = (superset, filter) ->
  match       = (model)  -> superset.contains(model) && filter(model)
  matching    = (models) -> toArray(models).select(match)
  nonMatching = (models) -> toArray(models).reject(match)

  reset = (collection) -> @reset(filter(collection.models))

  # TODO: redefine in terms of matching() and nonMatching() ?
  # TODO: also assert that it is still in the parent collection
  change = (model) ->
    if filter(model)
      @add(model)
    else
      @remove(model)

  class extends superset.constructor
    constructor: ->
      @__defineSetter__? "subsetFilter", @setSubsetFilter

      @bind 'filter', @applySubsetFilter
      superset.bind 'add',    @add, @
      superset.bind 'remove', @remove, @
      superset.bind 'reset',  reset, @
      superset.bind 'change', change, @

      super

    setSubsetFilter: (fn) =>
      filter = fn
      @trigger('filter')

    # TODO: test that this takes into consideration parent collection membership (filter() vs matching())
    applySubsetFilter: =>
      # TODO: performance gain can be made by running matching as a selection instead of once per item.
      #       easy way to do a set difference based on a collection selection?
      changes = superset.groupBy(match)
      @add    changes[true]
      @remove changes[false]

    add:    (models, options) -> super(matching    models, options)
    remove: (models, options) -> Backbone.Collection.prototype.remove.call(@, nonMatching models, options)

Backbone.Collection.prototype.subset = (filter = defaultFilter) ->
  Subset = subsetFor(@, filter)
  new Subset(@filter(filter), @options)

# Replace Backbone.Collection with a version that stores the passed
# in options so that we can restore them in the subset classes
class Backbone.Collection extends Backbone.Collection
  constructor: (_, @options) -> super

