InstrumentCollection = Parse.Collection.extend
  model: Instrument
  query: (new Parse.Query(Instrument))

collection = App.collection = new InstrumentCollection()

loadLocal = ->
  data = Parse.localStorage.getItem(Parse._getParsePath('instruments'))
  if data
    models = JSON.parse data
    instruments = []
    for model in models
      instr = new Parse.Object._create('Instrument')
      instr.id = model._id
      delete model._id
      instr.set model
      instr._refreshCache()
      instr._opSetQueue = [{}]
      instruments.push instr
    collection.add instruments
    return instruments.length
  return 0

saveLocal = ->
  models = []
  for instr in collection.models
    model = instr.toJSON()
    model._id = instr.id
    models.push model
  Parse.localStorage.setItem(Parse._getParsePath('instruments'), JSON.stringify(models))


reloadData = (callback, force=no) ->
  if not force
    try
      if loadLocal()
        return callback?()
    catch error
      console.log error
  console.log 'reloading instruments...'
  collection.fetch
    success: ->
      saveLocal()
      callback?()
    error: (error) =>
      callback?()
      console.log 'error'

App.InstrumentsTableView = Parse.View.extend
  className: 'table-wrapper'

  template: $.template 'table-instruments'

  initialize: ->
    @fields = ["name", "producer", "type", "group", "user_name", "status"]
  
  events:
    'keyup .search': 'search'
    'click tbody > tr': 'selectInstrument'
    'click .table-edit': 'editInstrument'
  
  render: ->
    if collection.isEmpty()
      @$el.html '<h4>Loading...</h4>'
      reloadData =>
        @$el.html @template fields:@fields, tools:collection
        @table = @$('table.table').dataTable()
      , yes
    @
  
  search: (event) ->
    term = event.target.value
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

  initialize: (id) ->
    if id?
      if collection.isEmpty()
        reloadData =>
          @model = collection.get id
          if @rendered
            @render()
        , yes
      else
        @model = collection.get id
    else
      @model = new Instrument()
    
  textField: (name, title, options={}) ->
    box = $('<div>', class:'field-box')
    box.append("<label>#{title}:</label>")
    tooltip = options.tooltip
    if tooltip
      delete options.tooltip
      $.extend options,
        'data-toggle': 'tooltip'
        'data-trigger': 'focus'
        'data-placement': 'right'
        'title': tooltip
    
    attrs =
      class:'span6 input-large inline-input'
      type:'text'
      name: name
      value: @model.get(name)
    $.extend attrs, options
    
    input = $('<input>', attrs)
    box.append input
    box[0].outerHTML
  
  chosenField: (name, title, options=[], chosen={}) ->
    box = $('<div>', class:'field-box')
    box.append("<label>#{title}:</label>")
    select = $('<select>', class:'chosen span6')
    select.prop('multiple', chosen.multiple)
    select.append('<option></option>')
    for option in options
      if $.isArray option
        select.append("<option value='#{option[0]}'>#{option[1]}</option>")
      else
        select.append("<option value='#{option}'>#{option}</option>")
    box.append select
    box[0].outerHTML
  
  dateField: (name, title) ->
    box = $('<div>', class:'field-box')
    box.append("<label>#{title}:</label>")
    picker = $ '<input>',
      class:'input-large inline-input span6 datepicker'
      type:'text'
      name: name
    box.append picker
    box[0].outerHTML
  
  events:
    'click .currency a': 'changeCurrency'
    'click .star': 'clickStar'
    'click .delete' : 'deleteInstrument'
    'click .save': 'save'
  
  changeDate: (event) ->
    console.log 'changeDate'
  render: ->
    @rendered = yes
    if not @model
      @$el.html '<h4>Loading...</h4>'
      return @
    @$el.html @template textField:@textField, chosenField:@chosenField, dateField:@dateField, model:@model
    @$('input:checkbox, input:radio').uniform()
    @$('input.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    
    @$('input.datepicker').each (i, el) =>
      date = @model.get(el.name) or new Date()
      $(el).data('datepicker').setDate(date)
    
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
  
  deleteInstrument: (event) ->
    
  save: (event) ->
    event.preventDefault()
    @model.set('acquisition_date', @$('input.datepicker[name=acquisition_date]').data('datepicker').getDate())
    @$('.field-box > input[type=text]').each (i, input) =>
      if input.name
        @model.set input.name, input.value
    
    groupACL = new Parse.ACL()
    groupACL.setRoleWriteAccess('octopus', yes)
    groupACL.setRoleReadAccess('octopus', yes)
    @model.setACL(groupACL)
    @model.save
      success: ->
        console.log 'saved!'
      error: (error) ->
        console.error error
