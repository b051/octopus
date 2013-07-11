InstrumentCollection = Parse.Collection.extend
  model: Instrument

collection = new InstrumentCollection()
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

App.InstrumentsTableView = Parse.View.extend
  className: 'table-wrapper'

  template: $.template 'table-instruments'

  initialize: ->
  
  events:
    'keyup .search': 'search'
    'click tbody > tr': 'selectInstrument'
    'click .table-edit': 'editInstrument'
  
  render: ->
    @$el.html @template fields:["name", "producer", "type", "group", "user", "status"], tools: collection
    @table = @$('table.table').dataTable()
    @
  
  search: (event) ->
    term = event.target.value
    console.log @table
    @table.fnFilter term, null
  
  selectInstrument: (event) ->
    tr = event.currentTarget
    checkbox = $('td.id input[type=checkbox]', tr)
    checkbox.prop('checked', !checkbox.prop('checked'))
  
  editInstrument: (event) ->
    link = $(event.target).parents('tr').find('a').attr('href')
    app.navigate link, yes
  
  deleteInstrument: (event) ->
    


App.InstrumentView = Parse.View.extend
  className: 'row-fluid form-wrapper'
  template: $.template 'form-instrument'
  textFieldTemplate: $.template 'widget-form-textfield'

  initialize: (cid) ->
    if cid?
      @model = collection.getByCid cid
    else
      @model = new Instrument()
  
  events:
    'click .currency a': 'changeCurrency'
    'click .star': 'clickStar'
  
  render: ->
    textField = (title, options) =>
      @textFieldTemplate title:title, options:options, value:@model.get(options.name)
    
    @$el.html @template textField:textField, model:@model
    @$('input:checkbox, input:radio').uniform()
    @$('.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    @$('.wysihtml5').wysihtml5
      'font-styles': no
    @$('.chosen').chosen disable_search_threshold: 10
    @$('input').tooltip()
    @
  
  clickStar: (event) ->
    star = $(event.target)
    star.siblings().removeClass('on')
    star.addClass('on')
  
  
  changeCurrency: (event) ->
    event.preventDefault()
    a = $(event.target)
    currency = a.text()
    a.parents('.currency').find('button').html currency
  
  save: ->
    groupACL = new Parse.ACL()
    groupACL.setRoleWriteAccess('octopus', yes)
    groupACL.setRoleReadAccess('octopus', yes)
    @model.setACL(groupACL)
    @model.save
      success: ->
        console.log 'saved!'
      error: (error) ->
        console.error error
