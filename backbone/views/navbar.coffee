dropdown = _.template $('#widget-dropdown').html()

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
      
      @searchForm ?= new NavSearchForm
      @notificationDropdown ?= new NavNotificationView
      @messagesDropdown ?= new NavMessagesView
      @$el.empty().append @searchForm.el, @notificationDropdown.el, @messagesDropdown.el, profileView
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
    @render()
  
  template: _.template $('#navbar-notification').html()
  
  render: ->
    @$el.html @template {}
    @


NavSearchForm = Parse.View.extend
  tagName: 'li'
  className: 'hidden-phone'
  
  initialize: ->
    @render()
  
  template: _.template $('#navbar-search').html()
  
  render: ->
    @$el.html @template {}
    @