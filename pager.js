// Generated by CoffeeScript 1.12.5
(function() {
  var CLASSNAME, Collection, LIMIT, STATE, TIMEOUT,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  STATE = {
    "on": "active",
    "off": "inactive",
    "finished": "finished",
    "error": "error",
    "timeout": "timeout",
    "notfound": "notfound"
  };

  CLASSNAME = STATE["off"];

  TIMEOUT = 10000;

  LIMIT = 5;

  Collection = (function(superClass) {
    extend(Collection, superClass);

    function Collection() {
      return Collection.__super__.constructor.apply(this, arguments);
    }

    Collection.prototype.model = (function(superClass1) {
      extend(_Class, superClass1);

      function _Class() {
        return _Class.__super__.constructor.apply(this, arguments);
      }

      _Class.prototype.html = function() {
        return this.get("html");
      };

      return _Class;

    })(Backbone.Model);

    Collection.prototype.initialize = function(models, opts) {
      return this.maxLength = opts.maxLength, this.timeout = opts.timeout, this.limit = opts.limit, opts;
    };

    Collection.prototype.parse = function(resp) {
      return resp.articles;
    };

    Collection.prototype.fetch = function() {
      return Collection.__super__.fetch.call(this, {
        timeout: this.timeout,
        add: true,
        remove: false,
        merge: false,
        data: {
          offset: this.length,
          limit: this.limit
        },
        success: (function(_this) {
          return function(col, resp) {
            if (resp.finished === true) {
              return _this.trigger("finished");
            }
          };
        })(this),
        error: (function(_this) {
          return function(col, xhr, opts) {
            if (opts.errorThrown === "timeout") {
              return _this.trigger("error:timeout");
            } else if (opts.errorThrown === "Not Found") {
              return _this.trigger("error:notfound");
            } else {
              return _this.trigger("error:error");
            }
          };
        })(this)
      });
    };

    return Collection;

  })(Backbone.Collection);

  module.exports = (function(superClass) {
    extend(_Class, superClass);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype.className = CLASSNAME;

    _Class.prototype.initialize = function(opts) {
      var ref, ref1, ref2;
      if (opts == null) {
        opts = {};
      }
      if (this.state == null) {
        this.state = (ref = opts.state) != null ? ref : STATE;
      }
      this.col = new Collection(null, {
        timeout: (ref1 = opts.timeout) != null ? ref1 : TIMEOUT,
        limit: (ref2 = opts.limit) != null ? ref2 : LIMIT
      });
      this.col.url = opts.url;
      this.listenTo(this.col, "add", (function(_this) {
        return function(model) {
          return _this.trigger("append", model);
        };
      })(this));
      this.listenTo(this.col, "finished", (function(_this) {
        return function() {
          _this.stopListening();
          return _this.$el.off();
        };
      })(this));
      this.listenTo(this.col, "error", (function(_this) {
        return function() {
          _this.stopListening();
          return _this.$el.off();
        };
      })(this));
      return this.listenTo(this.col, "all", this.render);
    };

    _Class.prototype.events = {
      "click": function() {
        var ref, ref1;
        if (!(((ref = this.xhr) != null ? ref.state() : void 0) === "pending" || ((ref1 = this.xhr) != null ? ref1.state() : void 0) === "rejected")) {
          return this.xhr = this.col.fetch();
        }
      }
    };

    _Class.prototype.render = function(event) {
      var matches;
      if (event.match(/request/)) {
        return this.$el.toggleClass(STATE["on"], true).toggleClass(STATE["off"], false);
      } else {
        this.$el.toggleClass(STATE["on"], false).toggleClass(STATE["off"], false);
        if (event.match(/finished/)) {
          return this.$el.toggleClass(STATE["finished"], true);
        } else if (matches = event.match(/error:(\w+)/)) {
          return this.$el.toggleClass(STATE[matches[1]], true);
        } else if (event.match(/sync/)) {
          return this.$el.toggleClass(STATE["off"], true);
        }
      }
    };

    return _Class;

  })(Backbone.View);

}).call(this);
