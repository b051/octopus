window.HomeView = Parse.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
    this
