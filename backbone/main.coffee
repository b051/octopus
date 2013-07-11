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
    charts: 'charts'
    instruments : 'tools'
    'instruments/add' : 'newInstrument'
    'instrument/:cid' : 'tool'
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
      view = next()
      @_switchMain view.el
      if Parse.history.fragment is ''
        $('#main-stats').slideDown()
      else
        $('#main-stats').slideUp()
      view.render()
  
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
      $('#main-stats').html new App.StatsView().el
      new App.HomeView
  
  account: (tab) ->
    @requireLogin ->
      new App.AccountView(tab)
  
  calendar: ->
    @requireLogin ->
      new App.CalendarView
  
  charts: ->
    @requireLogin ->
      new App.ChartsView
  
  tools: ->
    @requireLogin ->
      new App.InstrumentsTableView
  
  newInstrument: ->
    @requireLogin ->
      new App.InstrumentView

  tool: (cid) ->
    @requireLogin ->
      new App.InstrumentView cid