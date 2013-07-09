ToolCollection = Parse.Collection.extend
  model: Tool

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
  _id: "T003"
  name: 'Duke'
  producer: 'Apple'
  type: 'digit'
  group: 'etalon'
  user: 'Szabi'
  status: 0
]

App.ToolsTableView = Parse.View.extend
  className: 'table-wrapper products-table section'

  template: $.template 'table-measurings'

  initialize: ->

  events:
    'keyup .search': 'search'
    'click tbody > tr': 'selectTool'
  
  render: ->
    @$el.html @template fields:["name", "producer", "type", "group", "user", "status"], tools: collection
    @table = @$('table.table').dataTable()
    @
  
  search: (event) ->
    term = event.target.value
    console.log @table
    @table.fnFilter term, null
  
  selectTool: (event) ->
    tr = event.currentTarget
    checkbox = $('td.id input[type=checkbox]', tr)
    checkbox.prop('checked', !checkbox.prop('checked'))
    cid = $('td.id input[type=hidden]', tr).val()
    app.navigate "measuring/#{cid}", yes


App.ToolView = Parse.View.extend
  className: 'row-fluid form-wrapper'
  template: $.template 'form-measuring'
  textFieldTemplate: $.template 'widget-form-textfield'

  initialize: (cid) ->
    if cid?
      @model = collection.getByCid cid
    else
      @model = new Tool
  
  render: ->
    textField = (title, options) =>
      @textFieldTemplate title:title, options:options, value:@model.get(options.name)
    
    @$el.html @template textField:textField, model:@model
    @$('input:checkbox, input:radio').uniform()
    @$('.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    @$('.wysihtml5').wysihtml5
      'font-styles': no
    @$('.select2').chosen()
    @$('input').tooltip()
    @