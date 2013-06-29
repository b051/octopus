window.HomeView = Parse.View.extend
  className: 'row'
  
  initialize: ->
    @render()
  
  template: _.template $('#content-home').html()
  
  render: ->
    @$el.html @template {}
    @$('table').dataTable()
    @
