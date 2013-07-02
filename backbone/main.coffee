App.Zh_CN = {}

App.translate = App.Zh_CN

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
    'account': 'account'
    'account/:tab': 'account'

  initialize: ->
    @navbar = new App.NavBar
    @sidebar = new App.SideBar
    @navbar.render()
    @sidebar.render()
    Parse.history.on 'route', =>
      @sidebar.update()

  home: ->
    if not Parse.User.current()
      route = Parse.history.fragment
      if route not in ['login', 'signup']
        @navbar.update()
        return app.navigate 'login', yes
    else
      Parse.User.current().fetch()
      @_switchToLogin no
      @homeView = new App.HomeView
      @_switchMain @homeView.el
      console.log 'render navbar'
      @navbar.render()
      @sidebar.update()
  
  _switchMain: (el) ->
    $('.main>.container').empty().append el
  
  _switchToLogin: (toLogin) ->
    $('html')[if toLogin then 'addClass' else 'removeClass'] 'login-bg'
    $('#sidebar-nav, .navbar, body > .content')[if toLogin then 'hide' else 'show']()
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
  
  account: (tab) ->
    @_switchMain new App.AccountView(tab).el

