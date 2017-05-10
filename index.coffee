class Article extends Backbone.Model
  URL= ""
  class @Collection extends Backbone.Collection
    TIMEOUT= 5000
    filled: no
    initialize: (@page= 1)->
      @listenTo @, "error", (col,resp)=>
        unless resp.statusText.match /abort/
          if resp.statusText is "timeout" then @trigger "error:timeout"
          else if resp.status is 404      then @trigger "error:notfound"
          else                                 @trigger "error:error"

    url: ->"#{URL}/page/#{@page}"
    parse: (resp)->[{html: resp.html}]
    fetch: (method, model, opts)->
      @page++;
      super
        timeout: TIMEOUT, add: yes, remove: no, merge: no
    sync: (method, model, opts)=>
      MAX= 2
      jqxhr= $.Deferred()
      model.trigger "request", model, jqxhr, opts
      timeId= _.delay =>
        resp=
          statusText: "success"
          maxLength: MAX
          html: do (require "./lipsum.pug")
        jqxhr.resolve resp
        opts.success.call @, resp
        jqxhr.promise()
      , Math.random() * 2000
      _.extend jqxhr, abort: ->
        jqxhr.reject statusText: "abort"
        clearTimeout timeId
      jqxhr

new class Pager extends Backbone.View
  STATE=
    on: "fa-spin fa-spinner"
    off: "fa-caret-square-o-down"
    finished: "fa-caret-up"
    "error:error": "fa-warning"
    "error:timeout": "fa-warning"
    "error:notfound": "fa-warning"

  target: ".archive"
  className: "fa fa-5x fa-fw #{STATE["off"]}"
  collection: new Article.Collection
  events:
    click: ->@collection.fetch()

  initialize: ->
    $ =>@$el.appendTo @target
    #@autoKickWithScrolling()
    @listenTo @collection, "add", (model)=>
      @$el.before model.get "html"
    @listenTo @collection, "sync", (model, resp)=>
      @stopListening() if @collection.length is resp.maxLength
    @listenTo @collection, "error", (col,resp)=>
      @stopListening() unless resp.statusText.match /abort/
    @listenTo @collection, "all", (event)=>@toggle event

  toggle: (event)->
    if event.match /request/
      @$el
      .toggleClass STATE["on"], on
      .toggleClass STATE["off"], off
    else if event.match /^error:/
      @$el
      .toggleClass STATE["off"], off
      .toggleClass STATE["on"], off
      .toggleClass STATE[event], on
    else
      if @collection.filled
        @$el
        .toggleClass STATE["off"], off
        .toggleClass STATE["on"], off
        .toggleClass STATE["finished"], on
      else
        @$el
        .toggleClass STATE["off"], on
        .toggleClass STATE["on"], off

  autoKickWithScrolling: ->
    _.extend @collection,
      kick: (state)->
        if state
          if !@jqxhr? or @jqxhr.state() is "resolved"
            @page++; @jqxhr= @fetch()
        else
          if @jqxhr?.state() is "pending"
            @page--; @jqxhr.abort(); delete @jqxhr; @trigger "cancel";
    DELAY= 150
    THROTTLE_RATE= 100
    kick= _.debounce ((state)=>@collection.kick(state)), DELAY
    $(window).on "scroll", _.throttle =>
      kick do =>
        windowBottom= $(window).scrollTop() + $(window).height()
        pagerTop= @$el.offset().top + @$el.height()
        windowBottom >= pagerTop
    , THROTTLE_RATE, {trailing: on, leading: off}
