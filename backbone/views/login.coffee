App.SignupView = Parse.View.extend
  className: 'row-fluid login-wrapper'
  
  initialize: ->
    @user = new Parse.User()
    @render()
  
  template: _.template $('#content-signup').html()
  
  render: ->
    @$el.html(@template()).i18n().appendTo($('body'))
    @
  
  events:
    "submit form": "onSubmit"
    "click .login": "onSubmit"
  
  alert: (error)->
    App.Alert.show error, @$('.alert-wrapper').empty()
  
  onSubmit: (event) ->
    event.preventDefault()
    event.stopPropagation()
    email = @$('input[name=email]').val()
    password2 = @$('input[name=confirm_password]').val()
    password = @$('input[name=password]').val()
    if password2 isnt password
      return @alert "<b>Warning!</b> password does not match"
    @user.set 'username', email
    @user.set 'email', email
    @user.set 'password', password
    @user.set 'first_name', @$('input[name=first_name]').val()
    @user.set 'last_name', @$('input[name=last_name]').val()

    @user.signUp null,
      success: (user) ->
        app.navigate "", yes
      error: (user, error) =>
        @alert "<b>Warning!</b> #{error.message}"


App.LoginView = Parse.View.extend
  className: 'row-fluid login-wrapper'
  template: _.template $('#content-login').html()
  
  initialize: ->
    @user = new Parse.User()
    @render()
  
  render: ->
    @$el.html(@template()).appendTo($('body'))
    @
  
  events:
    "submit form": "onSubmit"
    "click .login": "onSubmit"
  
  alert: (error)->
    App.Alert.show error, @$('.alert-wrapper').empty()
  
  onSubmit: (event) ->
    event.stopPropagation()
    event.preventDefault()
    @user.set 'username', @$('input[name=username]').val()
    @user.set 'password', @$('input[name=password]').val()
    if not @user.isValid()
      $.msgbox @user.validationError
    else
      @user.logIn
        success: (user) ->
          app.navigate "", yes
        error: (user, error) =>
          @alert "<b>Warning!</b> #{error.message}"

