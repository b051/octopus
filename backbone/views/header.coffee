window.HeaderView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template()
    this
  
  events:
    "submit form": "onSubmit"
  
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
    dropdown = @$('#nav-login').addClass('dropdown').html("<a class='dropdown-toggle' data-toggle='dropdown' href='#me'>#{user.username} <b class='caret'></b></a>")
    ul = $('<ul/>', class:'dropdown-menu').append($('<li/>').append($('<a/>', href:'#logout', text:'Logout')))
    ul.appendTo dropdown
  
  selectMenuItem: (menuItem) ->
    $(".nav li").removeClass "active"
    $(".#{menuItem}").addClass "active" if menuItem
