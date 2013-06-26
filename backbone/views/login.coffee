window.UserView = Parse.View.extend
  initialize: ->
    @render()

  render: ->
    @model ?= new User
    $(@el).html @template(@model.toJSON())
    this

  events:
    "change": "validate"
    "submit form": "onSubmit"
  
  validate: (event) ->
    Alert.hide()
    
    # Apply the change to the model
    target = event.target
    @model.set target.id, target.value
    
    if not @model.isValid()
      errors = @model.validationError
      if errors[target.id]
        Alert.addValidationError target.id, errors[target.id]
  
  onSubmit: (event) ->
    event.preventDefault()
    
    if not @model.isValid()
      Alert.displayValidationErrors @model.validationError
    else
      @model.save null,
        success: (data) ->
          app.navigate "", trigger: yes
        
        error: (data) ->
          Alert.show "Error!", data.error, "alert-error"

window.SignupView = Parse.View.extend
  className: 'account-container register stacked'
  
  initialize: ->
    @extra = new SignupExtraView
    @render()
  
  template: Parse._.template($('#content-signup').html())
  
  render: ->
    @$el.html @template {}
    this
  
  
window.LoginView = Parse.View.extend
  className: 'account-container stacked'
  
  initialize: ->
    @extra = new LoginExtraView
    @render()
  
  template: Parse._.template($('#content-login').html())
  
  render: ->
    @$el.html @template {}
    this
  
  onSubmit: (event) ->
    event.preventDefault()
    
    if not @model.isValid()
      Alert.displayValidationErrors @model.validationError
    else
      $.post '/login', @model.toJSON(), (data) ->
        return Alert.show "Error!", data.error, "alert-error" if data.error
        app.navigate ""
        Alert.show "Success!", "Welcome back #{model.username}!", "alert-success"

LoginExtraView = window.UserView.extend
  className: 'login-extra'
  
  initialize: ->
    @render()
  
  template: Parse._.template($('#content-loginextra').html())
  
  render: ->
    @$el.html @template {}
    this

SignupExtraView = window.UserView.extend
  className: 'login-extra'
  
  initialize: ->
    @render()
  
  template: Parse._.template($('#content-signupextra').html())
  
  render: ->
    @$el.html @template {}
    this

