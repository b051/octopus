window.AboutView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
    this
