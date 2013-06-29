window.Alert = class Alert
  
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

  @show: (title, text, klass) ->
    $(".alert")
    .removeClass("alert-error alert-warning alert-success alert-info")
    .addClass(klass)
    .html("<strong>#{title}</strong> #{text}")
    .show()

  @hide: ->
    $(".help-inline").html ''
    $(".help-block").html ''
    $('.error').removeClass 'error'
    $(".alert").hide()

AppRouter = Parse.Router.extend
  routes:
    "": 'home'
    login: 'login'
    logout: 'logout'
    signup: 'signup'
    'account': 'account'
    'account/:tab': 'account'
    wines: "list"
    "wines/page/:page": "list"
    "wines/add": "addWine"
    "wines/:id": "wineDetails"
    about: "about"

  initialize: ->
    @navbar = new NavBar
    @subnavbar = new SubNavBar
    @navbar.render()
    @subnavbar.render()
    Parse.history.on 'route', =>
      @subnavbar.update()

  home: ->
    if not Parse.User.current()
      route = Parse.history.fragment
      if route not in ['login', 'signup']
        @navbar.update()
        return app.navigate 'login', yes
    else
      Parse.User.current().fetch()
      @_switchToLogin no
      @homeView = new HomeView
      @_switchMain @homeView.el
      console.log 'render navbar'
      @navbar.render()
      @subnavbar.update()
  
  _switchMain: (el) ->
    $('.main>.container').empty().append el
  
  _switchToLogin: (toLogin) ->
    @navbar.update()
    @subnavbar.update()
    $('.main >.container, .extra, .subnavbar-inner, .footer')[if toLogin then 'hide' else 'show']()
    $('.login-extra, .account-container.stacked').remove()
  
  login: ->
    @_switchToLogin yes
    new LoginView

  logout: ->
    Parse.User.logOut()
    @navbar.render()
    app.navigate '', yes
  
  signup: ->
    @_switchToLogin yes
    new SignupView
  
  account: (tab) ->
    @_switchMain new AccountView(tab).el
  
  list: (page) ->
    $('.header').fadeIn()
    p = (if page then parseInt(page, 10) else 1)
    wineList = new WineCollection()
    wineList.fetch success: ->
      $("#content").html new WineListView(
        model: wineList
        page: p
      ).el

    # @headerView.selectMenuItem "home-menu"

  wineDetails: (id) ->
    $('.header').fadeIn()
    wine = new Wine(_id: id)
    wine.fetch success: ->
      $("#content").html new WineView(model: wine).el

    # @headerView.selectMenuItem()

  addWine: ->
    wine = new Wine()
    $("#content").html new WineView(model: wine).el
    # @headerView.selectMenuItem "add-menu"

  about: ->
    template 'AboutView', =>
      @aboutView = new AboutView() unless @aboutView
      $("#content").html @aboutView.el
      # @headerView.selectMenuItem "about-menu"

window.app = new AppRouter()
Parse.history.start()
