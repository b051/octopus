window.NavBar = Parse.View.extend
  el: $('.nav-collapse')
  
  initialize: ->
    @render()
  
  render: ->
    if Parse.User.current()
      @profileView ?= new ProfileView
      @searchForm ?= new SearchForm
      @$el.empty().append @profileView.render().el, @searchForm.el
    else
      @noprofileView ?= new NoProfileView
      @$el.empty().append @noprofileView.el


NoProfileView = Parse.View.extend
  tagName: 'ul'
  className: 'nav pull-right'
  
  initialize: ->
    Parse.history.on 'route', (route, fragment, param) =>
      @$('.create-an-account').fadeTo(100, fragment isnt 'signup')
      @$('.back-to-home').fadeTo(100, fragment isnt 'home')
    @render()
  
  template: Parse._.template($('#navbar-noprofile').html())
  
  render: ->
    @$el.html @template {}
    this

ProfileView = Parse.View.extend
  tagName: 'ul'
  className: 'nav pull-right'
  
  initialize: ->
  
  template: Parse._.template($('#navbar-profile').html())
  
  render: ->
    @$el.html @template {user: Parse.User.current()}
    this
  
  events:
    "submit form.nav-login": "onSubmit"
  
  onSubmit: (event) ->
    event.preventDefault()
    user = new User
      username: @$('input[name=username]').val()
      password: @$('input[name=password]').val()
    if not user.isValid()
      Alert.displayValidationErrors user.validationError
    else
      $.post '/login', user.toJSON(), (data) =>
        if data.error
          app.navigate 'login', trigger: yes
        else
          @user data.user
  
  user: (user) ->
    console.log user
  
  selectMenuItem: (menuItem) ->
    $(".nav li").removeClass "active"
    $(".#{menuItem}").addClass "active" if menuItem


SearchForm = Parse.View.extend
  tagName: 'form'
  className: 'navbar-search pull-right'
  
  initialize: ->
    @render()
  
  template: Parse._.template($('#navbar-search').html())
  
  render: ->
    console.log @$el, @template {}
    @$el.html @template {}
    this
  
  
