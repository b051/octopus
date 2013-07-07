ToolCollection = Parse.Collection.extend
  model: Tool

App.HomeView = Parse.View.extend
  className: 'table-wrapper products-table section'

  template: $.template 'table-measurings'

  initialize: ->
  
  events:
    'keyup .search': 'search'
  
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
    ,
      name: 'S<carlett'
      manufacture: 'Microsoft'
      quantity: 200
      schedule: new Date 2013, 12, 12
    ]
    @$el.html @template {}
    @table = @$('table.table').dataTable()
    @table.delegate 'tbody > tr', 'click', (event) ->
      tr = $(event.target).parent('tr')
      number = $('td.sorting_1', tr).html()
      console.log number
    @
  
  search: (event) ->
    term = event.target.value
    console.log @table
    @table.fnFilter term, null