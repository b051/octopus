App.SideBar = Parse.View.extend
  el: $('#dashboard-menu')
  
  initialize: ->
    @arrow = $('<div>', class:'pointer').append $('<div>', class:'arrow'), $('<div>', class:'arrow_border')
    @render()
  
  template: _.template $('#sidebar-menu').html()
  
  render: ->
    @$el.html @template {}
  
  update: ->
    fragment = Parse.history.fragment
    activeTab = 0
    if fragment in ['charts']
      activeTab = 1
    @$('> li').each (index, li) =>
      if index is activeTab
        $(li).addClass('active', duration:200)
        .prepend(@arrow.detach())
      else
        $(li).removeClass 'active', duration:200