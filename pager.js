// Generated by CoffeeScript 1.12.5
(function() {
  var CLASSNAME, Collection, LIMIT, STATE, TARGET, TIMEOUT,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  STATE = {
    "on": "fa-spin fa-spinner active",
    "off": "fa-caret-square-o-down inactive",
    "finished": "fa-caret-up finished",
    "error": "fa-warning error",
    "timeout": "fa-warning timeout",
    "notfound": "fa-warning notfound"
  };

  CLASSNAME = "pager-indicator fa fa-5x fa-fw " + STATE["off"];

  TARGET = ".archive";

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
      var ref, ref1, ref2, ref3;
      if (opts == null) {
        opts = {};
      }
      if (this.target == null) {
        this.target = (ref = opts.target) != null ? ref : TARGET;
      }
      if (this.state == null) {
        this.state = (ref1 = opts.state) != null ? ref1 : STATE;
      }
      this.col = new Collection(null, {
        timeout: (ref2 = opts.timeout) != null ? ref2 : TIMEOUT,
        limit: (ref3 = opts.limit) != null ? ref3 : LIMIT
      });
      this.col.url = opts.url;
      $((function(_this) {
        return function() {
          return _this.$el.appendTo(_this.target);
        };
      })(this));
      this.listenTo(this.col, "add", (function(_this) {
        return function(model) {
          return _this.$el.before(model.html());
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
