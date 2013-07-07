App.SideBar = Parse.View.extend
  el: $('#dashboard-menu')
  
  initialize: ->
    @arrow = $('<div>', class:'pointer').append $('<div>', class:'arrow'), $('<div>', class:'arrow_border')
    @render()
  
  template: _.template $('#sidebar-menu').html()
  
  render: ->
    @$el.html @template {}
  
  events:
    'click .dropdown-toggle': 'toggleSubmenu'
  
  toggleSubmenu: (event) ->
    event.preventDefault()
    toggle = $(event.currentTarget)
    submenu = toggle.next 'ul.submenu'
    li = toggle.parent()
    if li.hasClass 'active'
      li.removeClass 'active'
      submenu.slideUp 'fast'
    else
      li.addClass 'active'
      submenu.slideDown 'fast'
        
  
  update: ->
    fragment = Parse.history.fragment
    activeTab = 0
    if fragment in ['charts']
      activeTab = 1
    if fragment in ['calendar']
      activeTab = 5
    @$('> li').each (index, li) =>
      if index is activeTab
        $(li).addClass('active', duration:200)
        .prepend(@arrow.detach())
      else
        $(li).removeClass 'active', duration:200