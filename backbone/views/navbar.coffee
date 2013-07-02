dropdown = _.template $('#widget-dropdown').html()

stopEvent = (event) ->
  event.stopPropagation()
  event.preventDefault()

App.NavBar = Parse.View.extend
  el: $('.nav')
  
  initialize: ->
    @render()
  
  render: ->
    if Parse.User.current()
      profileView = dropdown
        text:Parse.User.current().get('username')
        items:[['account', 'Personal info']
          ['account/settings', 'Account settings']
          ['export', 'Export your data']
          ''
          ['logout', 'Logout']]
      
      @searchForm = new NavSearchForm
      @notifications = new NavNotificationView
      @messagesDropdown = new NavMessagesView
      @$el.empty().append @searchForm.el, @notifications.el, @messagesDropdown.el, profileView
    else
      @$el.empty()
  
  update: ->
    @noprofileView?.update Parse.history.fragment


NavMessagesView = Parse.View.extend
  tagName: 'li'
  className: 'notification-dropdown hidden-phone'
  template: _.template $('#navbar-messages').html()
  
  initialize: ->
    @render()
  
  render: ->
    @$el.html @template {}
    @


NavNotificationView = Parse.View.extend
  tagName: 'li'
  className: 'notification-dropdown hidden-phone'
  
  initialize: ->
    $('body').click @closeMenu.bind @
    @render()
  
  template: _.template $('#navbar-notification').html()
  
  render: ->
    @$el.html @template {}
    @dialog = @$('.pop-dialog')
    @trigger = @$('.trigger')
    @
  
  events:
    'click .pop-dialog': 'stopEvent'
    'click .pop-dialog .close-icon': 'closeMenu'
    'click .trigger': 'openMenu'
  
  closeMenu: (event)->
    if event.target.className is 'close-icon'
      stopEvent(event)
    @dialog.removeClass('is-visible')
    @trigger.removeClass('active')
  
  stopEvent: (event) ->
    stopEvent(event)
  
  openMenu: (event) ->
    stopEvent(event)
    $(".notification-dropdown .pop-dialog").removeClass("is-visible")
    $(".notification-dropdown .trigger").removeClass("active")
    
    @dialog.toggleClass('is-visible')
    if @dialog.hasClass('is-visible')
      @trigger.addClass('avtive')
    else
      @trigger.removeClass('active')


NavSearchForm = Parse.View.extend
  tagName: 'li'
  className: 'hidden-phone'
  
  initialize: ->
    @render()
  
  template: _.template $('#navbar-search').html()
  
  render: ->
    @$el.html @template {}
    @
