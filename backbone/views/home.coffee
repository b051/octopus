ToolCollection = Parse.Collection.extend
  model: Tool

App.HomeView = Parse.View.extend
  className: 'row'

  template: _.template $('#content-home').html()

  initialize: ->
    @render()
  
  render: ->
    collection = new ToolCollection()
    collection.add [
      name: 'Duke'
      manufacture: 'Apple'
      quantity: 10
      schedule: new Date 2013, 10, 10
    ,
      name: 'Scarlett'
      manufacture: 'Microsoft'
      quantity: 200
      schedule: new Date 2013, 12, 12
    ]
    console.log collection
    @$el.html @template collection: collection
    @$('table').dataTable().delegate 'tbody > tr', 'click', (event) ->
      tr = $(event.target).parent('tr')
      number = $('td.sorting_1', tr).html()
      $.msgbox number
    @
