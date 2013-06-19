window.Wine = Backbone.Model.extend
  urlRoot: "/wines"
  idAttribute: "_id"
  
  validate: (attrs, options) ->
    errors = {}
    errors.name = "You must enter a name" unless attrs.name.length > 0
    errors.grapes = "You must enter a grape variety" unless attrs.grapes.length > 0
    errors.country = "You must enter a country" unless attrs.country.length > 0
    if Object.keys(errors).length
      return errors
    no
  
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
