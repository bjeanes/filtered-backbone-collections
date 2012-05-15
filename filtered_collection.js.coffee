# TODO: Use bjeanes' SubsettableCollection which does 90% of this already
Backbone.Collection.prototype.subset = (fn) ->
  superset = this
  Superset = superset.constructor

  filter = {fn: fn || -> true }

  select = (items, fn) ->
    items = if _.isArray(items) then items else [items]
    _(items).select(fn)

  reject = (items, fn) ->
    select(items, -> !fn.apply(@, arguments))

  class Subset extends Superset
    initialize: =>
      @__defineSetter__ "subsetFilter", (fn) =>
        filter.fn = fn
        @trigger('filter')

      @bind 'filter', @applySubsetFilter
      superset.bind 'add',    @add
      superset.bind 'remove', @remove
      superset.bind 'reset',  (collection) => @reset(filter.fn(collection.models))
      superset.bind 'change', (model) =>
        matches = filter.fn(model)

        if matches && !@contains(model)
          @add(model)
          return

        if !matches && @contains(model)
          @remove(model)
          return

      super

    applySubsetFilter: =>
      superset.each (model) =>
        if filter.fn(model)
          @add(model)
        else
          @remove(model)

    add: (models, options) =>
      models = select models, (model) -> superset.contains(model) && filter.fn(model)
      superset.add.call(@, models, options)

    remove: (models, options) =>
      models = reject models, (model) -> superset.contains(model) && filter.fn(model)
      superset.remove.call(@, models, options)

  new Subset(superset.filter(filter.fn))

