InstrumentCollection = Parse.Collection.extend
  model: Instrument
  query: (new Parse.Query(Instrument))

collection = App.collection = new InstrumentCollection()

reloadData = (callback) ->
  console.log 'reloading instruments...'
  collection.fetch
    success: ->
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
    @$el.html @template fields:@fields, tools:collection
    if not @table
      @reloadData()
      @table = @$('table.table').dataTable()
    else
      @table.fnDraw()
    @
  
  reloadData: (event) ->
    if collection.isEmpty()
      reloadData =>
        @render()

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
          console.log 'reloaded'
          @model = collection.get id
          console.log @model
          if @rendered
            @render()
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
  
  events:
    'click .currency a': 'changeCurrency'
    'click .star': 'clickStar'
    'click .delete' : 'deleteInstrument'
    'click .save': 'save'
  
  render: ->
    @rendered = yes
    return if not @model
    @$el.html @template textField:@textField, chosenField:@chosenField, model:@model
    @$('input:checkbox, input:radio').uniform()
    @$('input.datepicker').datepicker().on 'changeDate', (event) ->
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
  
  deleteInstrument: (event) ->
    
  save: (event) ->
    event.preventDefault()
    @model.set('acquisition_date', @$('input.datepicker').data('datepicker').getDate())
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
