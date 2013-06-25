window.HeaderView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
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
