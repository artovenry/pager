module.exports= class extends Backbone.View
  TIMEOUT= 10000
  LIMIT= 5
  events: "click": ->
    @xhr= @col.fetch() unless @xhr?.state() is "pending" or @xhr?.state() is "rejected"
  initialize: (opts= {})->
    @toggle off
    @col= new Collection null, timeout: opts.timeout ? TIMEOUT, limit: opts.limit ? LIMIT
    @col.url= opts.url
    @listenTo @col, "finished",              ->@stopListening(); @$el.off()
    @listenTo @col, "error",                 ->@stopListening(); @$el.off()
    @listenTo @col, "all",                   @change
    @listenTo @col, "add",                   (model)->@trigger "append", model
  change: (event)->
    switch event
      when "request"  then @toggle on
      when "sync"     then @toggle off
      when "finished"
        @toggle off
        @$el.addClass "finished"
      else
        if matches= event.match /error:(\w+)/
          @toggle off
          @$el.addClass matches[1]

  toggle: (state)->@$el.toggleClass "active", state
  class Collection extends Backbone.Collection
    FETCH_OPTS= add: yes, remove: no, merge: no
    model: class extends Backbone.Model
      html: ->@get "html"
    initialize: (models, opts)-> {@timeout, @limit}= opts
    parse: (resp)->resp.articles
    fetch: -> super _.extend FETCH_OPTS,
      timeout: @timeout, data: {offset: @length , limit: @limit}
      success: (col, resp)=> @trigger "finished" if resp.finished is yes
      error: (col, xhr, opts)=>
        if      opts.errorThrown  is  "timeout"  then @trigger "error:timeout"
        else if opts.errorThrown  is  "Not Found"then @trigger "error:notfound"
        else                                          @trigger "error:error"
