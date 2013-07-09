ToolCollection = Parse.Collection.extend
  model: Tool

App.MeasuringView = Parse.View.extend
  className: 'table-wrapper products-table section'

  template: $.template 'table-measurings'

  initialize: ->
  
  events:
    'keyup .search': 'search'
  
  render: ->
    collection = new ToolCollection()
    collection.add [
      _id: "T001"
      name: 'Duke'
      producer: 'Apple'
      type: 'digit'
      group: 'etalon'
      user: 'Szabi'
      status: 1
    ,
      _id: "T002"
      name: 'Duke'
      producer: 'Apple'
      type: 'digit'
      group: 'etalon'
      user: 'Szabi'
      status: 1
    ,
      _id: "T002"
      name: 'Duke'
      producer: 'Apple'
      type: 'digit'
      group: 'etalon'
      user: 'Szabi'
      status: 0
    ]
    @$el.html @template fields:["name", "producer", "type", "group", "user", "status"], tools: collection
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

    
App.AddMeasuringView = Parse.View.extend
  className: 'row-fluid form-wrapper'
  template: $.template 'form-measuring'
  textFieldTemplate: $.template 'widget-form-textfield'

  initialize: (@model) ->
  
  render: ->
    textField = (title, options) =>
      @textFieldTemplate title:title, options:options
    
    @$el.html @template textField:textField, model:@model?.toJSON()
    @$('input:checkbox, input:radio').uniform()
    @$('.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    @$('.wysihtml5').wysihtml5
      'font-styles': no
    @$('.select2').chosen()
    @$('input').tooltip()
    @