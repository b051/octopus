window.Paginator = Parse.View.extend
  className: "pagination pagination-centered"
  initialize: ->
    @model.bind "reset", @render, this
    @render()

  render: ->
    items = @model.models
    len = items.length
    pageCount = Math.ceil(len / 8)
    $(@el).html "<ul />"
    for i in [1..pageCount]
      cssClass = if i is @options.page then "'active'" else ""
      $("ul", @el).append "<li class=#{cssClass}><a href='#wines/page/#{i}'>#{i}</a></li>"
    this
