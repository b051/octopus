window.Paginator = Backbone.View.extend
  className: "pagination pagination-centered"
  initialize: ->
    @model.bind "reset", @render, this
    @render()

  render: ->
    items = @model.models
    len = items.length
    pageCount = Math.ceil(len / 8)
    $(@el).html "<ul />"
    i = 0

    while i < pageCount
      cssClass = if (i + 1) is @options.page then "'active'" else ""
      $("ul", @el).append "<li class=#{cssClass}><a href='#wines/page/#{i + 1}'>#{i + 1}</a></li>"
      i++
    this
