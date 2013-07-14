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


all_fields =
  name: "Name"
  producer: "Producer"
  type: "Type"
  group: "Group"
  user_name: "Username"
  status: "Status"
  acquisition_price: "acquisition price"
  acquisition_date: "acquisition date"
  available_licenses: "available_licenses"
  base_of_rank: "base_of_rank"
  deliverer: "deliverer"
  deliverer_code: "deliverer_code"
  main_instrument: "main_instrument"
  ordering_number: "ordering_number"
  precision: "precision"
  range: "range"
  rank: "rank"
  scale: "scale"
  sn: "sn"
  state: "state"
  store_price: "store_price"
  user_department: "user_department"
  user_address: "user_address"
  user_phone: "user_phone"
  user_email: "user_email"
  user_fax: "user_fax"


reloadData = (callback, force=no) ->
  if not force
    try
      if loadLocal()
        collection.fetch
          success: ->
            console.log "fetched"
            saveLocal()
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

viewConnect = ->
  if collection.isEmpty()
    @$el.html '<h4>Loading...</h4>'
    reloadData =>
      @_render()
  else
    @_render()
  collection.on('reset', @_render.bind @)


App.InstrumentsTableView = Parse.View.extend
  className: 'table-wrapper'

  template: $.template 'table-instruments'
  
  itemTemplate: _.template '<li class="item">
              <i class="icon-reorder"></i>
              <%= title %>
              <input type="checkbox" <% if (checked) { %>checked<% } %> class="check">
            </li>'
  
  popUpTemplate: '<div class="pop-dialog" style="position:absolute;">
      <div class="pointer">
        <div class="arrow"></div>
        <div class="arrow_border"></div>
      </div>
      <div class="body">
        <div class="settings">
          <a href="#" class="close-icon"><i class="icon-remove-sign"></i></a>
          <ul class="items">
          </ul>
        </div>
      </div>
    </div>'

  initialize: ->
    @fields = ["name", "producer", "type", "group", "user_name", "status"]
    @place = @place.bind @
    
    mousedown = (e) ->
      closest = $(e.target).closest('.pop-dialog')
      if closest.length is 0
        @closePopup e
    @mousedown = mousedown.bind @
  
  events:
    'keyup .search': 'search'
    'click tbody > tr': 'selectInstrument'
    'click .table-edit': 'editInstrument'
    'click .custom-columns': 'openPopup'
  
  _render: ->
    console.log arguments
    @$el.html @template fields:@fields, tools:collection
    @table = @$('table.table').dataTable()
  
  render: ->
    viewConnect.apply @
    @
  
  openPopup: (event) ->
    event.stopPropagation()
    event.preventDefault()
    if not @picker
      @picker = $ @popUpTemplate
      @picker.appendTo 'body'
      $('.close-icon', @picker).on 'click', @closePopup.bind @
    @picker.addClass('is-visible')
    items = @picker.find('.items').empty()
    for key, title of all_fields
      checked = key in @fields
      items.append @itemTemplate title:title, checked: checked
    items.sortable()
    items.disableSelection()
    @$('.btn-group').removeClass('open')
    $(document).on 'mousedown', @mousedown
    $(window).on('resize', @place)
    @place.apply @
  
  closePopup: (event) ->
    $(document).off 'mousedown', @mousedown
    @picker.removeClass('is-visible')
    $(window).off 'resize', @place
  
  place: ->
    element = @$('.custom-columns')
    offset = element.offset()
    height = element.outerHeight(yes)
    @picker.css
      top: offset.top + height + 10
      left: offset.left
      width: 354
  
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

  initialize: (@instrumentId) ->
  
  _box: (title) ->
    box = $('<div>', class:'field-box')
    box.append("<label>#{title}:</label>")
  
  textField: (name, title, options={}) ->
    box = @_box title
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
    if tooltip
      input.tooltip()
    box.append input
  
  chosenField: (name, title, options=[], chosen={}) ->
    box = @_box title
    select = $('<select>', class:'chzn-select span6', name: name)
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
    box
  
  dateField: (name, title) ->
    box = @_box title
    picker = $ '<input>',
      class:'input-large inline-input span6 datepicker'
      type:'text'
      name: name
    
    date = @model.get(name) or new Date()
    picker.datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    picker.data('datepicker').setDate(date)
    box.append picker
  
  rateField: (name, title, number) ->
    box = @_box title
    rating = $('<span>', class:'rating')
    value = @model.get(name)
    for num in [0...number]
      star = $('<span>', class:'star')
      if num is value
        star.addClass 'on'
      rating.append star
    box.append rating
  
  currencyField: (name, title, symbols) ->
    box = @_box title
    currency = $('<div>', class:'input-prepend input-append span6 currency')
    match = @model.get(name).match /(.)(\d+)(\.\d+)/
    symbolPicker = $('<div>', class:'btn-group')
    button = $('<button class="btn dropdown-toggle" data-toggle="dropdown"></button>')
    symbolList = $('<ul>', class:'dropdown-menu')
    for symbol in symbols
      symbolList.append $('<li>').append($('<a>', href:'#', html:symbol))
    symbolPicker.append button, symbolList
    
    input = $('<input>', class:'input-large span8 text-right', type:'text', name:name)
    fraction = $('<span>', class:'add-on')
    currency.append symbolPicker, input, fraction
    button.html match[1]
    input.val match[2]
    fraction.html match[3]
    box.append currency
  
  events:
    'click .currency a': 'changeCurrency'
    'click .star': 'clickStar'
    'click .delete' : 'deleteInstrument'
    'click .save': 'save'
  
  _render: ->
    console.log arguments
    
    if @instrumentId
      @model = collection.get @instrumentId
      if not @model
        return app.navigate '', yes
    else
      @model = new Instrument()
    @$el.html @template model:@model
    
    basic_data = @$('.basic-data')
    basic_data.append @textField('iid', 'Identity number', {tooltip:'Instrument identify number'})
    basic_data.append @textField('name', 'Name', {tooltip:'Instrument name'})
    basic_data.append @textField('producer', 'Producer')
    basic_data.append @textField('sn', 'Serial number')
    basic_data.append @textField('range', 'Range')
    basic_data.append @textField('scale', 'Scale')
    basic_data.append @textField('precision', 'Precision')
    basic_data.append @chosenField('group', 'Group', ['auditing instrument', 'not auditing intr.', 'etalon', 'dummy'])
    basic_data.append @chosenField('state', 'State', [
      'closed', 'lost', 'wasted'
      'repairing', 'may use', 'destroyed'
      'calibrated over', 'is calibrating'
      'discharged', 'reserve'], 'multiple':yes)
    
    basic_data.append @rateField('rank', 'Rank', 5)
    basic_data.append @textField('base_of_rank', 'Base of rank')
    basic_data.append @textField('main_instrument', 'Main instrument')
    basic_data.append @textField('parts_of_instrument', 'Parts of instrument')
    
    user = @$('.instrument-user')
    user.append @textField('deliverer', 'Deliverer')
    user.append @textField('deliverer_code', 'Deliverer Code')
    user.append @textField('ordering_number', 'Ordering number')
    user.append @textField('available_licenses', 'Available licenses')
    user.append @currencyField 'acquisition_price', 'Acquisition price', ['$', '¥']
    user.append @currencyField 'store_price', 'Store price', ['$', '¥']
    user.append @dateField('acquisition_date', 'Date of acquisition')
    user.append @textField('user_name', 'Username')
    user.append @textField('user_department', 'Department')
    user.append @textField('user_address', 'Address')
    user.append @textField('user_phone', 'Phone')
    user.append @textField('user_fax', 'Fax')
    user.append @textField('user_email', 'Email', {'type':'email'})
    @$('.chzn-select').chosen()
  
  
  render: ->
    if @instrumentId
      viewConnect.apply @
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
