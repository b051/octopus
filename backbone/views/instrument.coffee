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
  iid: "Identity number"
  name: "Name"
  producer: "Producer"
  type: "Type"
  sn: "Serial number"
  group: "Group"
  range: "Range"
  scale: "Scale"
  state: "State"
  rank: "Rank"
  base_of_rank: "Base of rank"
  main_instrument: "Main instrument"
  parts_of_instrument: "Parts of instrument"
  acquisition_price: "Acquisition price"
  acquisition_date: "Date of acquisition"
  available_licenses: "Available licenses"
  deliverer: "Deliverer"
  deliverer_code: "Deliverer code"
  ordering_number: "Ordering number"
  precision: "Precision"
  store_price: "Store price"
  user_name: "Username"
  user_department: "Department"
  user_address: "Address"
  user_phone: "Phone"
  user_email: "Email"
  user_fax: "Fax"


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
    console.log 'reloadData'
    reloadData =>
      @_render()
  else
    console.log '_render'
    @_render()
  collection.on('reset', @_render.bind @)


App.InstrumentsTableView = Parse.View.extend
  className: 'table-wrapper'

  template: $.template 'table-instruments'

  itemTemplate: _.template '<li class="item" name="<%=name%>">
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
    @table?.dataTable().fnDestroy()
    @$el.html @template all_fields:all_fields, collection:collection
    @table = @$('table.table').dataTable
      bAutoWidth: no
      aoColumnDefs:[
        aTargets: [0]
        bVisible: no
      ,
        aTargets: [1]
        mRender: (data, type, row) ->
          return "<a href='#instrument/#{row[0]}'>#{data}</a>"
      ,
        aTargets: [15]
        mRender: (data) ->
          date = new Date(data)
          y = date.getFullYear()
          m = date.getMonth() + 1
          d = date.getDate()
          "#{m}/#{d}/#{y}"
      ,
        aTargets: [10]
        mRender: (data) ->
          rating = $('<span>', class:'rating')
          value = Number data
          for num in [0...5]
            star = $('<span>', class:'star')
            if num is value
              star.addClass 'on'
            rating.append star
          rating[0].outerHTML
      ,
        aTargets: [6, 9]
        mRender: (data) ->
          labels = _.map data.split(','), (value) ->
            '<span class="label label-success">' + value + '</span> '
          labels.join('')
      ]
    
    totalCount = Object.keys(all_fields).length + 1
    @orders = [0...totalCount]
    @all_fields = Object.keys(all_fields)
    @setFields ["iid", "name", "producer", "type", "group", "state", "rank", "acquisition_date", "user_name", "user_email"]
  
  setFields: (fields) ->
    @fields = []
    for i in fields
      @fields.push i
    fields = Object.keys all_fields
    for i in [0...fields.length]
      @table.fnSetColumnVis(i + 1, fields[i] in @fields)
  
  setOrders: (orders) ->
    col = null
    for inst in ColReorder.aoInstances
      if inst.s.dt.oInstance is @table
        col = inst
        break
    @orders = []
    for i in orders
      @orders.push i
    console.log 'setOrders', orders
    col?._fnOrderColumns orders
  
  render: ->
    viewConnect.apply @
    @
  
  changeTable: (event, options) ->
    if event.type is 'sortstop'
      console.log arguments
      changed = options.item.attr 'name'
      console.log changed
      orders = [0]
      
      new_fields = $('.item', @items).map ->
        $(@).attr 'name'
      new_fields = new_fields.toArray()
      window.new_fields = new_fields
      console.log new_fields
      for field in @all_fields
        index = new_fields.indexOf(field)
        orders.push index + 1
      @all_fields = new_fields
      @setOrders orders
    
    else if event.type is 'change'
      fields = []
      $('.item', @items).each ->
        field = $(@).attr 'name'
        if $('input', @).is ':checked'
          fields.push field
      @setFields fields
  
  openPopup: (event) ->
    event.stopPropagation()
    event.preventDefault()
    if not @picker
      @picker = $ @popUpTemplate
      @picker.appendTo 'body'
      $('.close-icon', @picker).on 'click', @closePopup.bind @
      $('.items', @picker).sortable
        cursor: 'move'
        stop: @changeTable.bind @
  
    @picker.addClass('is-visible')
    @items = items = @picker.find('.items').empty()
    
    for key in @all_fields
      title = all_fields[key]
      checked = key in @fields
      items.append @itemTemplate name:key, title:title, checked:checked
    items.disableSelection()
    $('input[type=checkbox]', items).on 'change', @changeTable.bind @
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
    @picker.focus()

  search: (event) ->
    term = event.target.value
    @table.fnFilter term, null

  selectInstrument: (event) ->
    tr = event.currentTarget
    match = $(tr).find('.iid a').attr('href').match /#instrument\/(.*)/
    iid = match[1]
    wrapper = @$el.siblings('.instrumentview')
    if not wrapper.length
      wrapper = $('<div>', class:'instrumentview section')
      @$el.parent().append wrapper
    console.log @$el, wrapper
    instrumentView = new App.InstrumentView(iid, yes)
    wrapper.html instrumentView.el
    instrumentView.render()

  editInstrument: (event) ->
    link = $(event.target).parents('tr').find('a').attr('href')
    app.navigate link, yes

  deleteInstrument: (event) ->
  


App.InstrumentView = Parse.View.extend

  className: 'row-fluid form-wrapper'

  template: $.template 'form-instrument'

  initialize: (@instrumentId, @usetabs) ->

  _box: (name) ->
    title = all_fields[name]
    box = $('<div>', class:'field-box')
    box.append("<label>#{title}:</label>")

  textField: (name, options={}) ->
    box = @_box name
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

  chosenField: (name, options=[], chosen={}) ->
    box = @_box name
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

  dateField: (name) ->
    box = @_box name
    picker = $ '<input>',
      class:'input-large inline-input span6 datepicker'
      type:'text'
      name: name
  
    date = @model.get(name) or new Date()
    picker.datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    picker.data('datepicker').setDate(date)
    box.append picker

  rateField: (name, number) ->
    box = @_box name
    rating = $('<span>', class:'rating')
    value = @model.get(name)
    for num in [0...number]
      star = $('<span>', class:'star')
      if num is value
        star.addClass 'on'
      rating.append star 
    box.append rating

  currencyField: (name, symbols) ->
    box = @_box name
    currency = $('<div>', class:'input-prepend input-append span6 currency')
    match = @model.get(name)?.match /(.)(\d+)(\.\d+)/
    symbolPicker = $('<div>', class:'btn-group')
    button = $('<button class="btn dropdown-toggle" data-toggle="dropdown"></button>')
    symbolList = $('<ul>', class:'dropdown-menu')
    for symbol in symbols
      symbolList.append $('<li>').append($('<a>', href:'#', html:symbol))
    symbolPicker.append button, symbolList
  
    input = $('<input>', class:'input-large span8 text-right', type:'text', name:name)
    fraction = $('<span>', class:'add-on')
    currency.append symbolPicker, input, fraction
    if match
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
    
    if @instrumentId
      @model = collection.get @instrumentId
      if not @model
        return app.navigate '', yes
    else
      @model = new Instrument()
    @$el.html @template model:@model, usetab: @usetabs
    
    basic_data = @$('.basic-data')
    basic_data.append @textField 'iid', {tooltip:'Instrument identify number'}
    basic_data.append @textField 'name', {tooltip:'Instrument name'}
    basic_data.append @textField 'producer'
    basic_data.append @textField 'sn'
    basic_data.append @textField 'range'
    basic_data.append @textField 'scale'
    basic_data.append @textField 'precision'
    basic_data.append @chosenField 'group', ['auditing instrument', 'not auditing intr.', 'etalon', 'dummy']
    basic_data.append @chosenField 'state', [
      'closed', 'lost', 'wasted'
      'repairing', 'may use', 'destroyed'
      'calibrated over', 'is calibrating'
      'discharged', 'reserve'], 'multiple':yes
 
    basic_data.append @rateField 'rank', 5
    basic_data.append @textField 'base_of_rank'
    basic_data.append @textField 'main_instrument'
    basic_data.append @textField 'parts_of_instrument'
 
    user = @$('.instrument-user')
    user.append @textField  'deliverer'
    user.append @textField 'deliverer_code'
    user.append @textField 'ordering_number'
    user.append @textField 'available_licenses'
    user.append @currencyField 'acquisition_price', ['$', '¥']
    user.append @currencyField 'store_price', ['$', '¥']
    user.append @dateField 'acquisition_date'
    user.append @textField 'user_name'
    user.append @textField 'user_department'
    user.append @textField 'user_address'
    user.append @textField 'user_phone'
    user.append @textField 'user_fax'
    user.append @textField 'user_email', {'type':'email'}
    @$('.chzn-select').chosen()

  render: ->
    if @instrumentId
      viewConnect.apply @
    else
      @_render()
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
