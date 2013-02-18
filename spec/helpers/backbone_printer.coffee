Backbone.Model.prototype.jasmineToString = (withAttributes = true) ->
  klass = @constructor.name || "Model"

  if @id
    id = "id: #{JSON.stringify(@id)}"
  else
    id = "cid: #{JSON.stringify(@cid)}"

  if withAttributes
    attributes = JSON.stringify(@toJSON())
    attributes = ", attributes: #{attributes}"
  else
    attributes = ""

  "{(#{klass}) #{id}#{attributes}}"

Backbone.Collection.prototype.jasmineToString = ->
  klass = @constructor.name || "Collection"
  models = _.map(@models, (m) -> m.jasmineToString(true))

  "{(#{klass}) length: #{@length}, models: [#{models.join(', ')}]}"