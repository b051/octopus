dropdown = $.template 'widget-dropdown'

minsAgo = (mins) ->
  new Date(new Date().getTime() - mins * 60 * 1000)


timeElapse = (time) ->
  now = new Date()
  if not _.isDate(time)
    time = new Date(time['iso'])
  
  elaspe = now.getTime() - time.getTime()
  if elaspe < 86400000
    mins = Math.floor elaspe / 60000
    hours = Math.floor mins / 60
    mins -= hours * 60
    if hours
      return "#{hours} hours"
    else
      return "#{mins} mins"
  else
    return time.toLocaleDateString()


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


NavNotificationDropDown = Parse.View.extend
  
  tagName: 'li'
  
  className: 'notification-dropdown hidden-phone'
  
  events:
    'click .pop-dialog': 'stopEvent'
    'click .pop-dialog .close-icon': 'closeMenu'
    'click .trigger': 'openMenu'
  
  initialize: ->
    $('body').click @closeMenu.bind @
    @render()
    @dialog = @$('.pop-dialog')
    @trigger = @$('.trigger')
  
  closeMenu: (event) ->
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


NavMessagesView = NavNotificationDropDown.extend
  
  template: $.template 'navbar-notification'
  messageTemplate: $.template 'widget-message'
  
  render: ->
    @$el.html @template icon: 'icon-envelope-alt', type: 'messages'
    
    collection = new MessageCollection()
    collection.add [
      title: 'Alejandra Galván'
      detail: 'There are many variations of available, but the majority have suffered alterations.'
      thumbnail: 'img/contact-img.png'
      time: minsAgo 48
    ,
      title: 'Alejandra Galván'
      detail: 'There are many variations of available, have suffered alterations.'
      thumbnail: 'img/contact-img2.png'
      time: minsAgo 26
    ,
      title: 'Alejandra Galván'
      detail: 'There are many variations of available, but the majority have suffered alterations.'
      thumbnail: 'img/contact-img.png'
      time: minsAgo 13
    ]
    
    collection.each @addMessage.bind @
    @$('.count').html if collection.length then collection.length else ''
    @
  
  addMessage: (message) ->
    html = @messageTemplate _.extend message.toJSON(), timeElapse: timeElapse
    @$('.messages').prepend html


NavNotificationView = NavNotificationDropDown.extend
  
  template: $.template 'navbar-notification'
  notificationTemplate: $.template 'widget-notification'
  
  render: ->
    @$el.html @template icon: 'icon-warning-sign', type: 'notifications'
    @$('.notifications').prepend '<h3>You have <span class="count"></span> new notifications</h3>'
    objects = [
      type: 'signin'
      content: 'New user registration'
      time: minsAgo 13
    ,
      type: 'signin'
      content: 'New user registration'
      time: minsAgo 18
    ,
      type: 'envelope-alt'
      content: 'New message from Alejandra'
      time: minsAgo 28
    ,
      type: 'download-alt'
      content: 'New order placed'
      time: minsAgo 1440
    ]
    _.each objects, @addNotification.bind @
    @$('.count').html if objects.length then objects.length else ''
    @
  
  addNotification: (notification) ->
    html = @notificationTemplate _.extend notification, timeElapse: timeElapse
    @$('.notifications .footer').before html


NavSearchForm = Parse.View.extend
  tagName: 'li'
  className: 'hidden-phone'
  
  initialize: ->
    @render()
  
  template: $.template 'navbar-search'
  
  render: ->
    @$el.html @template {}
    @

