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
    wines: "list"
    "wines/page/:page": "list"
    "wines/add": "addWine"
    "wines/:id": "wineDetails"
    about: "about"

  initialize: ->
    @navbar = new NavBar
    @navbar.render()
  
  home: ->
    if not Parse.User.current()
      route = Parse.history.fragment
      if route not in ['login', 'signup']
        return app.navigate 'login', trigger:yes
    
    $('.header').fadeIn()
    @homeView = new HomeView() unless @homeView
    $("#content").html @homeView.el

  login: ->
    console.log 'login'
    $('.subnavbar').remove()
    $('.main').remove()
    $('.extra').hide()
    $('.footer').hide()
    @loginView ?= new LoginView
    $('.footer').before @loginView.el, @loginView.extra.el

  logout: ->
    $.post '/logout', (data) =>
      app.navigate '', trigger: yes
      @reloadNav()
  
  signup: ->
    console.log 'signup'
    $('.subnavbar').remove()
    $('.main').remove()
    $('.extra').hide()
    $('.footer').hide()
    $(@loginView?.el).remove()
    $(@loginView?.extra.el).remove()
    @signupView ?= new SignupView
    $('.footer').before @signupView.el, @signupView.extra.el

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

views = ["HomeView", "WineView", "WineListItemView"]
template = (view, done) ->
  $.get "tpl/#{view}.html", (data) ->
    temp = Parse._.template(data)
    window[view]::template = temp if window[view]
    done?(temp)

$.when.apply(null, (template(view) for view in views when window[view])).done ->
  window.app = new AppRouter()
  Parse.history.start()
