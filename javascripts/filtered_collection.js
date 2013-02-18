(function() {
  var defaultFilter, subsetFor, toArray,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  defaultFilter = function() {
    return true;
  };

  toArray = function(items) {
    return _(_.isArray(items) ? items : [items]);
  };

  subsetFor = function(superset, filter) {
    var Subset, change, match, matching, nonMatching, reset;
    match = function(model) {
      return superset.contains(model) && filter(model);
    };
    matching = function(models) {
      return toArray(models).select(match);
    };
    nonMatching = function(models) {
      return toArray(models).reject(match);
    };
    reset = function(collection) {
      return this.reset(filter(collection.models));
    };
    change = function(model) {
      if (filter(model)) {
        return this.add(model);
      } else {
        return this.remove(model);
      }
    };
    return Subset = (function(_super) {

      __extends(Subset, _super);

      function Subset() {
        this.applySubsetFilter = __bind(this.applySubsetFilter, this);

        this.setSubsetFilter = __bind(this.setSubsetFilter, this);
        if (typeof this.__defineSetter__ === "function") {
          this.__defineSetter__("subsetFilter", this.setSubsetFilter);
        }
        this.bind('filter', this.applySubsetFilter);
        superset.bind('add', this.add, this);
        superset.bind('remove', this.remove, this);
        superset.bind('reset', reset, this);
        superset.bind('change', change, this);
        Subset.__super__.constructor.apply(this, arguments);
      }

      Subset.prototype.setSubsetFilter = function(fn) {
        filter = fn;
        return this.trigger('filter');
      };

      Subset.prototype.applySubsetFilter = function() {
        var changes;
        changes = superset.groupBy(match);
        this.add(changes[true]);
        return this.remove(changes[false]);
      };

      Subset.prototype.add = function(models, options) {
        return Subset.__super__.add.call(this, matching(models, options));
      };

      Subset.prototype.remove = function(models, options) {
        return Backbone.Collection.prototype.remove.call(this, nonMatching(models, options));
      };

      return Subset;

    })(superset.constructor);
  };

  Backbone.Collection.prototype.subset = function(filter) {
    var Subset;
    if (filter == null) {
      filter = defaultFilter;
    }
    Subset = subsetFor(this, filter);
    return new Subset(this.filter(filter), this.options);
  };

  Backbone.Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection(_, options) {
      this.options = options;
      Collection.__super__.constructor.apply(this, arguments);
    }

    return Collection;

  })(Backbone.Collection);

}).call(this);
