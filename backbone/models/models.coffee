window.Wine = Backbone.Model.extend
  urlRoot: "/wines"
  idAttribute: "_id"
  
  defaults:
    _id: null
    name: ""
    grapes: ""
    country: "USA"
    region: "California"
    year: ""
    description: ""
    picture: null
  
  validate: (attrs, options) ->
    errors = {}
    errors.name = "You must enter a name" unless attrs.name.length
    errors.grapes = "You must enter a grape variety" unless attrs.grapes.length
    errors.country = "You must enter a country" unless attrs.country.length
    if Object.keys(errors).length
      return errors
    no

window.WineCollection = Backbone.Collection.extend
  model: Wine
  url: "/wines"

window.User = Backbone.Model.extend
  url: '/user'
  
  defaults:
    username: ''
    password: ''
  
  validate: (attrs, options) ->
    errors = {}
    errors.username = "You must enter your username" unless attrs.username.length > 6
    errors.password = "You must enter your password" unless attrs.password.length >= 6
    if Object.keys(errors).length
      return errors
    no
  
    