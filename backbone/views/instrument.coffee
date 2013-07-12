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
  
  _render: ->
    @$el.html @template fields:@fields, tools:collection
    @table = @$('table.table').dataTable()
  
  render: ->
    if collection.isEmpty()
      @$el.html '<h4>Loading...</h4>'
      reloadData =>
        @_render()
      , yes
    else
      @_render()
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
    select = $('<select>', class:'chosen span6', name: name)
    select.prop('multiple', chosen.multiple)
    select.append('<option></option>')
    
    value = @model.get(name)
    for arr in options
      option = $('<option>')
      
      if $.isArray arr
        option.val(arr[0])
        option.html(arr[1])
        select.append("<option value='#{option[0]}'>#{option[1]}</option>")
      else
        option.val(arr)
        option.html(arr)
      if $.isArray value
        option.attr('selected', option.val() in value)
      else
        option.attr('selected', option.val() is value)
      select.append option
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
    
    rank = @model.get('rank')
    if rank >= 0
      $(@$('.rating .star')[rank]).addClass('on')
    
    for key in ['store_price', 'acquisition_price']
      input = @$("input[name=#{key}]")
      match = @model.get(key).match /(.)(\d+)(\.\d+)/
      c = input.parent()
      $('button', c).html match[1]
      input.val match[2]
      $('.add-on', c).html match[3]
    
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
    $(event.target).attr('disabled', yes).html('Saving...')
    @model.set('rank', @$('.rating .star').index(@$('.rating .on')))
    
    @$('.field-box > input, .field-box > select').each (i, input) =>
      key = input.name
      if key
        field = $(input)
        if field.hasClass('datepicker')
          @model.set(key, field.data('datepicker').getDate())
        else
          @model.set key, field.val()
    
    @$('.currency').each (i, div) =>
      c = $(div)
      currency = $('button', c).text()
      fraction = $('.add-on', c).text()
      input = $('input', c)
      val = currency + input.val() + fraction
      @model.set(input.attr('name'), val)
    
    groupACL = new Parse.ACL()
    groupACL.setRoleWriteAccess('octopus', yes)
    groupACL.setRoleReadAccess('octopus', yes)
    @model.setACL(groupACL)
    @model.save
      success: ->
        console.log 'saved!'
        $(event.target).html('Saved!').removeClass('primary').addClass('success')
        setTimeout ->
          $(event.target).html('Save').attr('disabled', no).removeClass('success').addClass('primary', 200)
        , 2000
      error: (error) ->
        $(event.target).html('Save').attr('disabled', no)
        console.error error
