App.Zh_CN = {}

App.translate = App.Zh_CN

$.template = (name) ->
  _.template $("##{name}").html()

App.Buffer =
  commands: []
  
  add: (fn) ->
    commands = @commands
    commands.push(fn)
    if @commands.length is 1
      fn(next)
    next = ->
      commands.shift()
      if commands.length
        commands[0](next)


$.fn.extend
  textNodes: ->
    whitespace = /^\s*$/
    @contents().filter ->
      @nodeType is Node.TEXT_NODE and not whitespace.test(@nodeValue)
  
  i18n: ->
    $('*', @).textNodes().each ->
        @data = App.translate[@data] or @data
    
    $('input', @).attr 'placeholder', (index, value) ->
      App.translate[value] or value
    @

class App.Alert
  
  @displayValidationErrors: (messages) ->
    for key, message of messages
      @addValidationError key, message
    @show "Warning!", "Fix validation errors and try again", "alert-warning"

  @addValidationError: (field, message) ->
    controlGroup = $("input[name=#{field}]").parents('.control-group')
    controlGroup.addClass "error"
    $(".help-inline", controlGroup).html message
    $(".help-block", controlGroup).html message

  @removeValidationError: (field) ->
    controlGroup = $("input[name=#{field}]").parents('.control-group')
    controlGroup.removeClass "error"
    $(".help-inline", controlGroup).html ""
    $(".help-block", controlGroup).html ""

  @show: (warning, appendTo = $('body')) ->
    alert = $('<div>', class:'alert').append($('<button>', class:'close', 'data-dismiss':'alert', type:'button', html:'&times;'), warning)
    console.log alert, warning
    alert.appendTo(appendTo)

  @hide: ->
    $(".help-inline").html ''
    $(".help-block").html ''
    $('.error').removeClass 'error'
    $(".alert").hide()

App.Router = Parse.Router.extend
  routes:
    "": 'home'
    login: 'login'
    logout: 'logout'
    signup: 'signup'
    analytics: 'analytics'
    instruments : 'instruments'
    'instruments/add' : 'newInstrument'
    'instrument/:cid' : 'instrument'
    calendar: 'calendar'
    'account': 'account'
    'account/:tab': 'account'

  initialize: ->
    @navbar = new App.NavBar
    @sidebar = new App.SideBar
    @navbar.render()
    @sidebar.render()
    Parse.history.on 'route', =>
      @sidebar.update()

  requireLogin: (next) ->
    if not Parse.User.current()
      route = Parse.history.fragment
      if route not in ['login', 'signup']
        return app.navigate 'login', yes
    else
      @_switchToLogin no
      @navbar.render()
      @content = next()
      @_switchMain @content.el
      @content.render()
      if Parse.history.fragment is 'analytics'
        $('#main-stats').show()
      else
        $('#main-stats').slideUp()
  
  _switchMain: (el) ->
    $('#pad-wrapper').empty().append el
  
  _switchToLogin: (toLogin) ->
    $('html')[if toLogin then 'addClass' else 'removeClass'] 'login-bg'
    $('#sidebar-nav, .navbar, #pad-wrapper')[if toLogin then 'hide' else 'show']()
    $('.header')[if toLogin then 'show' else 'hide']()
    $('.login-wrapper').remove()
    @sidebar.update()
  
  login: ->
    @_switchToLogin yes
    new App.LoginView

  logout: ->
    Parse.User.logOut()
    @navbar.render()
    app.navigate '', yes
  
  signup: ->
    @_switchToLogin yes
    new App.SignupView
  
  home: ->
    @requireLogin ->
      Parse.User.current().fetch()
      new App.InstrumentsTableView
  
  account: (tab) ->
    @requireLogin ->
      new App.AccountView(tab)
  
  calendar: ->
    @requireLogin ->
      new App.CalendarView
  
  analytics: ->
    @requireLogin ->
      $('#main-stats').html new App.StatsView().el
      new App.ChartsView
  
  instruments: ->
    @requireLogin ->
      new App.InstrumentsTableView
  
  newInstrument: ->
    @requireLogin ->
      new App.InstrumentView

  instrument: (id) ->
    @requireLogin ->
      new App.InstrumentView id