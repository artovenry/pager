STATE=
  on              : "fa-spin fa-spinner"
  off             : "fa-caret-square-o-down"
  finished        : "fa-caret-up"
  "error:error"   : "fa-warning"
  "error:timeout" : "fa-warning"
  "error:notfound": "fa-warning"
CLASSNAME= "fa fa-5x fa-fw #{STATE["off"]}"
TARGET= ".archive"
TIMEOUT= 10000
LIMIT= 5

class Collection extends Backbone.Collection
  filled: no
  model: class extends Backbone.Model
    html: ->@get "html"
  initialize: (models, opts)->
    {@maxLength, @timeout, @limit}= opts
    @listenTo @, "sync" , (col, resp)=>
      @filled= resp.last is yes
    @listenTo @, "error", (col,resp)=>
      unless resp.statusText.match /abort/
        if      resp.statusText  is  "timeout"  then @trigger "error:timeout"
        else if resp.status      is  404        then @trigger "error:notfound"
        else                                         @trigger "error:error"
  parse: (resp)->resp.articles
  fetch: ->
    super
      timeout: @timeout, add: yes, remove: no, merge: no
      data: offset: @length , limit: @limit

module.exports= class extends Backbone.View
  className: CLASSNAME
  initialize: (opts={})->
    @target?= opts.target ? TARGET
    @state?= opts.state ? STATE
    @col= new Collection null, timeout: opts.timeout ? TIMEOUT, limit: opts.limit ? LIMIT
    $ =>@$el.appendTo @target

    @listenTo @col, "add",    (model)        => @$el.before model.html()
    @listenTo @col, "sync",   (model, resp)  => @stopListening() if @col.filled
    @listenTo @col, "error",  (col, resp)    => @stopListening() unless resp.statusText.match /abort/
    @listenTo @col, "all",    (event)        => @render event

  events: click: ->
    @xhr= @col.fetch() unless @xhr?.state() is "pending"

  render: (event)->
    console.log event
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
      if @col.filled
        @$el
        .toggleClass STATE["off"], off
        .toggleClass STATE["on"], off
        .toggleClass STATE["finished"], on
      else
        @$el
        .toggleClass STATE["off"], on
        .toggleClass STATE["on"], off

