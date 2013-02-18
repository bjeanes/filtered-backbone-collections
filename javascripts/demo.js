$(function() {
  var Items = Backbone.Collection.extend();
  var ItemView = Backbone.View.extend({
    tagName: "li",

    events: {
      "click .delete": "destroy"
    },

    initialize: function() {
      this.listenTo(this.model, "destroy", this.remove);
      this.listenTo(this.model, "change", this.render);
    },

    render: function() {
      this.$el.html(" <span class=\"shape\">" + this.entity() + "</span> " + this.model.cid);
      this.$el.css("color", this.model.get("color"));
      this.$el.prepend($("<span class=\"delete\">X</span>"));
      return this;
    },

    entity: function() {
      switch(this.model.get("shape")) {
      case "square":
        return "&#9632;"
      case "parallelogram":
        return "&#9648";
      case "triangle":
        return "&#9650";
      case "diamond":
        return "&#9670";
      case "rectangle":
        return "&#9644";
      case "circle":
        return "&#9679";
      default:
        return "";
      }
    },

    destroy: function() {
      this.model.destroy();
    }
  });

  window.items = new Items([
    {shape: "square", color: "red"},
    {shape: "circle", color: "blue"},
    {shape: "square", color: "green"},
    {shape: "triangle", color: "red"},
    {shape: "rectangle", color: "purple"},
    {shape: "square", color: "red"}
  ]);

  var ListView = Backbone.View.extend({
    initialize: function() {
      this.reset();
      this.listenTo(this.collection, "add", this.add);
    },

    add: function(model) {
      var view = new ItemView({
        model: model
      });

      view.render().$el.appendTo(this.$el);
    },

    reset: function() {
      // FIXME: delete old views
      var view = this;
      this.collection.each(function(model) {
        view.add(model);
      });
    }
  });

  window.listAll = new ListView({
    el: $("#demo ul.all"),
    collection: window.items
  });

  window.listSquares = new ListView({
    el: $("#demo ul.squares"),
    collection: window.items.subset(function(item) {
      return item.get("shape") == "square";
    })
  });

  window.listRedSquares = new ListView({
    el: $("#demo ul.red-squares"),
    collection: window.listSquares.collection.subset(function(item) {
      return item.get("color") == "red";
    })
  });
});
