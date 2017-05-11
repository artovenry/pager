class MockXhr
  constructor: (opts)->
    fail= opts.fail ? no
    _.extend @, (@df= $.Deferred())
    _.delay =>
      unless fail
        @df.resolve "hoge", "STATUS_SUCCESS", @df
        opts.success.call opts.context, "hoge"
      else
        @df.reject  @df, "STATUS_ERROR", "ERR"
        opts.error.call opts.context, @df, "booe", "ERR"
      @df.promise()
    , 100

sync= (method, model, opts)->
  error= opts.error
  opts.error= (xhr, textStatus, errorThrown)->
    opts.textStatus = textStatus
    opts.errorThrown = errorThrown
    if error then error.call opts.context, xhr, textStatus, errorThrown
  xhr= new MockXhr opts
  model.trigger "request", model, xhr, opts
  xhr

m= new class extends Backbone.Model
  url: "http://192.168.1.2:30001/mockServer.php"
  initialize: ->
    @listenTo @, "all", (e)->console.log e


xhr= m.fetch
  success: (model, resp, opts)->console.log arguments
  error:   (model, resp, opts)->console.log arguments
  timeout: 100
  data: fail: "error"

xhr.fail (xhr,textStatus, errorThrown)->console.log xhr

# xhr.then _.noop
# _.delay ->
#   xhr.abort()
# , 1000

###
"success", "notmodified", "nocontent", "error", "timeout", "abort", or "parsererror"
###