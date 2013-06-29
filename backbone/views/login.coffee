window.SignupView = Parse.View.extend
  className: 'account-container register stacked'
  
  initialize: ->
    @user = new Parse.User()
    @render()
  
  template: _.template $('#content-signup').html()
  extraTemplate: _.template $('#content-signupextra').html()
  
  render: ->
    @$el.html @template()
    $('.footer').before @$el, @extraTemplate()
    @
  
  events:
    "change": "change"
    "submit form": "onSubmit"
  
  change: (event) ->
    @user.set event.target.id, event.target.value
  
  onSubmit: (event) ->
    event.preventDefault()
    
    confirm_password = @user.get('confirm_password')
    @user.unset('confirm_password')
    
    firstname = @user.get('firstname')
    lastname = @user.get('lastname')
    @user.set('username', "#{firstname} #{lastname}")
    firstChoice = @user.get('Field')
    if firstChoice
      @user.unset('Field')
    else
       $.msgbox 'You have to agree the Term of Services'
       return
    
    if not @user.isValid()
      $.msgbox @user.validationError
    else
      @user.signUp null,
        success: (user) ->
          app.navigate "", yes
        error: (user, error) ->
          $.msgbox error, type:'error'


window.LoginView = Parse.View.extend
  className: 'account-container stacked'
  
  initialize: ->
    @user = new Parse.User()
    @render()
  
  template: _.template $('#content-login').html()
  extraTemplate: _.template $('#content-loginextra').html()
  
  render: ->
    @$el.html @template()
    $('.footer').before @$el, @extraTemplate()
    @
  
  events:
    "change": "change"
    "submit form": "onSubmit"
  
  change: (event) ->
    @user.set event.target.id, event.target.value
  
  onSubmit: (event) ->
    event.preventDefault()
    @user.set 'username', @$('#username').val()
    @user.set 'password', @$('#password').val()
    console.log @user.isValid()
    if not @user.isValid()
      $.msgbox @user.validationError
    else
      @user.logIn
        success: (user) ->
          app.navigate "", yes
        error: (user, error) ->
          $.msgbox error.message, type:'error'

