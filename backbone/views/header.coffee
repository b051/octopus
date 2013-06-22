window.HeaderView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
    this

  selectMenuItem: (menuItem) ->
    $(".nav li").removeClass "active"
    $(".#{menuItem}").addClass "active" if menuItem
