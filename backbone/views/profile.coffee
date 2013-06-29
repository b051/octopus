window.ProfileView = Parse.View.extend
  className: 'row'
  
  template: _.template $('#content-profile').html()
  
  initialize: ->
    @render()
  
  render: ->
    @attrs = Parse.User.current().attributes
    @$el.html @template user: @attrs
    @
  
  events:
    'submit #edit-profile': 'onSubmit'
    'change input': 'change'
    'click .btn-cancel': 'onCancel'
  
  change: (event) ->
    @attrs[event.target.id] = event.target.value
  
  onCancel: (event) ->
    event.preventDefault()
    app.navigate '', yes
  
  onSubmit: (event) ->
    event.preventDefault()
    user = Parse.User.current()
    user.save @attrs,
      success: (user) ->
        app.navigate '', yes
      error: (user, error) ->
        $.msgbox error.message, type:'error'
