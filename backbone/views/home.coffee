window.HomeView = Parse.View.extend
  className: 'row'
  
  initialize: ->
    @render()
  
  template: _.template $('#content-home').html()
  
  render: ->
    @$el.html @template {}
    @$('table').dataTable().delegate 'tbody > tr', 'click', (event) ->
      tr = $(event.target).parent('tr')
      number = $('td.sorting_1', tr).html()
      $.msgbox number
    @
