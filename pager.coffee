STATE=
  "on"            : "active"
  "off"           : "inactive"
  "finished"      : "finished"
  "error"         : "error"
  "timeout"       : "timeout"
  "notfound"      : "notfound"
CLASSNAME= STATE["off"]
TIMEOUT= 10000
LIMIT= 5

class Collection extends Backbone.Collection
  model: class extends Backbone.Model
    html: ->@get "html"
  initialize: (models, opts)->
    {@maxLength, @timeout, @limit}= opts
  parse: (resp)->resp.articles
  fetch: -> super
    timeout: @timeout, add: yes, remove: no, merge: no
    data: offset: @length , limit: @limit
    success: (col, resp)=> @trigger "finished" if resp.finished is yes
    error: (col, xhr, opts)=>
      if      opts.errorThrown  is  "timeout"  then @trigger "error:timeout"
      else if opts.errorThrown  is  "Not Found"then @trigger "error:notfound"
      else                                          @trigger "error:error"
 
module.exports= class extends Backbone.View
  className: CLASSNAME
  initialize: (opts={})->
    @state?= opts.state ? STATE
    @col= new Collection null, timeout: opts.timeout ? TIMEOUT, limit: opts.limit ? LIMIT
    @col.url= opts.url
    @listenTo @col, "add",                   (model)=> @trigger "append", model
    @listenTo @col, "finished",              =>@stopListening(); @$el.off()
    @listenTo @col, "error",                 =>@stopListening(); @$el.off()
    @listenTo @col, "all",                   @render

  events: "click": ->
    @xhr= @col.fetch() unless @xhr?.state() is "pending" or @xhr?.state() is "rejected"

  render: (event)->
    if event.match /request/
      @$el
      .toggleClass STATE["on"], on
      .toggleClass STATE["off"], off
    else
      @$el
      .toggleClass STATE["on"], off
      .toggleClass STATE["off"], off
      if event.match /finished/
        @$el.toggleClass STATE["finished"], on
      else if matches= event.match /error:(\w+)/
        @$el.toggleClass STATE[matches[1]], on
      else if event.match /sync/
        @$el.toggleClass STATE["off"], on
