SIZE= 5
testSync= (method, model, opts)->
  df= $.Deferred()
  error= opts.error
  opts.error= (xhr, textStatus, errorThrown)->
    opts.textStatus = textStatus
    opts.errorThrown = errorThrown
    if error then error.call opts.context, xhr, textStatus, errorThrown


  model.trigger "request", model, df, opts
  timeId= _.delay =>
    resp=
      statusText: "success"
      status: 200
      articles: do ->
        from= opts.data.offset
        to= if (ub= from + opts.data.limit) > SIZE then SIZE else ub
        html: (require "./lipsum.pug")(page: i) for i in[from...to]
    resp.last= yes if opts.data.offset + opts.data.limit >= SIZE
    df.resolve resp
    opts.success.call @, resp
    df.promise()
  , _.random(1, 20) * 100
  _.extend df, abort: ->
    df.reject statusText: "abort"
    clearTimeout timeId


timeoutTestSync= (method, model, opts)->
  df= $.Deferred()
  error= opts.error
  opts.error= (xhr, textStatus, errorThrown)->
    opts.textStatus = textStatus
    opts.errorThrown = errorThrown
    if error then error.call opts.context, xhr, textStatus, errorThrown

  model.trigger "request", model, df, opts
  _.delay =>
    resp= statusText: "timeout"
    df.reject resp
    opts.error.call @, resp
    df.promise()
  , _.random(1, 20) * 100
  df

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


# pager= new (require "./pager.coffee") limit: 2
# pager.col.sync= timeoutTestSync # DEV
require "./mockXhr.coffee"