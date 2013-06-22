window.UserView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    @model ?= new User
    $(@el).html @template(@model.toJSON())
    this

  events:
    "blur input": "validate"
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
          app.navigate ""
          Alert.show "Success!", "Welcome back #{model.username}!", "alert-success"
        
        error: (data) ->
          Alert.show "Error!", data.error, "alert-error"


window.LoginView = window.UserView.extend

  onSubmit: (event) ->
    event.preventDefault()
    
    if not @model.isValid()
      Alert.displayValidationErrors @model.validationError
    else
      $.post '/login', @model.toJSON(), (data) ->
        return Alert.show "Error!", data.error, "alert-error" if data.error
        app.navigate ""
        Alert.show "Success!", "Welcome back #{model.username}!", "alert-success"
