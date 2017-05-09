class Article extends Backbone.Model
  initialize: ->@set "html", do (require "./lipsum.pug")
  class @Collection extends Backbone.Collection
    kick: ->console.log "KICK"

# Bootstrap
$ ->
  $(".archive")
  .append ->
    articles= new Article.Collection do ->
      new Article for [0...5]
    a.get "html" for a in articles.models

new class Pager extends Backbone.View
  DELAY= 700
  THROTTLE_RATE= 100
  className: "pager  fa fa-5x fa-fw"
  collection: new Article.Collection

  initialize: ->
    $ =>@$el.appendTo ".archive"
    @toggle "indicating"
    kick= _.debounce (=>@collection.kick()), DELAY
    $(window).on "scroll", _.throttle =>
      if @shown() then do kick 
    , THROTTLE_RATE, {trailing: off, leading: off}


  shown: ->
    windowBottom= $(window).scrollTop() + $(window).height()
    pagerTop= @$el.offset().top
    windowBottom >= pagerTop

  toggle: (state)->
    switch state
      when "loading"
        @$el
        .toggleClass "fa-spin fa-spinner", on
        .toggleClass "fa-caret-square-o-down", off
      when "indicating"
        @$el
        .toggleClass "fa-caret-square-o-down", on
        .toggleClass "fa-spin fa-spinner", off
      else  #"indicating"
        @$el
        .toggleClass "fa-caret-square-o-down", on
        .toggleClass "fa-spin fa-spinner", off
