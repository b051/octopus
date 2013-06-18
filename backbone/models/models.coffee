window.Wine = Backbone.Model.extend
  urlRoot: "/wines"
  idAttribute: "_id"
  initialize: ->
    @validators = {}
    @validators.name = (value) ->
      if value.length > 0
        isValid: true
      else
        isValid: false
        message: "You must enter a name"

    @validators.grapes = (value) ->
      if value.length > 0
        isValid: true
      else
        isValid: false
        message: "You must enter a grape variety"

    @validators.country = (value) ->
      if value.length > 0
        isValid: true
      else
        isValid: false
        message: "You must enter a country"

  validateItem: (key) ->
    if @validators[key]
      @validators[key] @get(key)
    else
      isValid: true
  
  # TODO: Implement Backbone's standard validate() method instead.
  validateAll: ->
    messages = {}
    for key of @validators
      if @validators.hasOwnProperty(key)
        check = @validators[key](@get(key))
        messages[key] = check.message unless check.isValid
    if _.size(messages) > 0
      isValid: false
      messages: messages
    else
      isValid: true

  defaults:
    _id: null
    name: ""
    grapes: ""
    country: "USA"
    region: "California"
    year: ""
    description: ""
    picture: null

window.WineCollection = Backbone.Collection.extend
  model: Wine
  url: "/wines"
