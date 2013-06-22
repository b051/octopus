window.HomeView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
    this
