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
    if toggle.hasClass 'active'
      toggle.removeClass 'active'
      submenu.slideUp 'fast'
    else
      toggle.addClass 'active'
      submenu.slideDown 'fast'
        
  
  update: ->
    fragment = Parse.history.fragment
    activeTab = switch
      when fragment is 'charts' then 1
      when fragment.match /^measurings/ then 2
      when fragment.match /^users/ then 3
      when fragment.match /^calendar/ then 4
      else 0
    
    @$('> li').each (index, li) =>
      if index is activeTab
        $(li).addClass('active', duration:200)
        .prepend(@arrow.detach())
      else
        $(li).removeClass 'active', duration:200