window.WineListView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    wines = @model.models
    len = wines.length
    startPos = (@options.page - 1) * 8
    endPos = Math.min(startPos + 8, len)
    $(@el).html "<ul class=\"thumbnails\"></ul>"
    i = startPos

    while i < endPos
      $(".thumbnails", @el).append new WineListItemView(model: wines[i]).render().el
      i++
    $(@el).append new Paginator(
      model: @model
      page: @options.page
    ).render().el
    this

window.WineListItemView = Backbone.View.extend
  tagName: "li"
  initialize: ->
    @model.bind "change", @render, this
    @model.bind "destroy", @close, this

  render: ->
    $(@el).html @template(@model.toJSON())
    this

