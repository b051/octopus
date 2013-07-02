App.AccountView = Parse.View.extend
  className: 'row'
  
  template: _.template $('#content-account').html()
  
  initialize: (@tab = 'profile') ->
    @render()
  
  render: ->
    @$el.html @template
      tab: @tab
      profile: new App.EditProfileView
      settings: new App.AccountSettingsView
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
    event.stopPropagation()
    event.preventDefault()
    user = Parse.User.current()
    user.save @attrs,
      success: (user) ->
        app.navigate '', yes
      error: (user, error) ->
        $.msgbox error.message, type:'error'


App.EditProfileView = Parse.View.extend
  
  template: _.template $('#form-edit-profile').html()
  
  initialize: ->
    @render()
  
  render: ->
    @attrs = Parse.User.current().attributes
    @$el.html @template user: @attrs
  
  events: ->
    'submit form': 'onSubmit'
    'change input': 'change'
    'click .btn-cancel': 'onCancel'
  
  change: (event) ->
    @attrs[event.target.id] = event.target.value
  
  onCancel: (event) ->
    event.stopPropagation()
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

App.AccountSettingsView = Parse.View.extend
  
  template: _.template $('#form-account-settings').html()
  
  initialize: ->
    @render()
  
  render: ->
    @$el.html @template()
  

    