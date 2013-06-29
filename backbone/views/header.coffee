dropdown = _.template $('#widget-dropdown').html()

window.NavBar = Parse.View.extend
  el: $('.nav-collapse')
  
  initialize: ->
    @render()
  
  render: ->
    if Parse.User.current()
      @profileView ?= new NavProfileView
      @searchForm ?= new NavSearchForm
      @$el.empty().append @profileView.render().el, @searchForm.el
    else
      @noprofileView ?= new NavNoProfileView
      @$el.empty().append @noprofileView.el
  
  update: ->
    @noprofileView?.update Parse.history.fragment


NavNoProfileView = Parse.View.extend
  tagName: 'ul'
  className: 'nav pull-right'
  
  initialize: ->
    @render()
  
  template: _.template $('#navbar-noprofile').html()
  
  update: (fragment) ->
    @$('.create-an-account').fadeTo(100, fragment isnt 'signup')
    @$('.back-to-home').fadeTo(100, fragment isnt 'home')
  
  render: ->
    @$el.html @template {}
    this


NavProfileView = Parse.View.extend
  tagName: 'ul'
  className: 'nav pull-right'
  
  initialize: ->
  
  template: _.template $('#navbar-profile').html()
  
  render: ->
    @$el.html @template user: Parse.User.current(), dropdown:dropdown
    @


NavSearchForm = Parse.View.extend
  tagName: 'form'
  className: 'navbar-search pull-right'
  
  initialize: ->
    @render()
  
  template: _.template $('#navbar-search').html()
  
  render: ->
    @$el.html @template {}
    this

window.SubNavBar = Parse.View.extend
  className: 'container'
  
  template: _.template $('#subnavbar-container').html()
  
  update: ->
    fragment = Parse.history.fragment
    activeTab = 0
    if fragment in ['elements', 'validation', 'jqueryui', 'charts', 'popups']
      activeTab = 1
    else if fragment in ['pricing', 'faq', 'gallery', 'reports', 'account']
      activeTab = 2
    else if fragment in ['error']
      activeTab = 3
    $('.mainnav > li').each (index, li) ->
      if index is activeTab
        $(li).addClass 'active', duration:200
      else
        $(li).removeClass 'active', duration:200
  
  render: ->
    $('.subnavbar-inner').empty().append(@$el)
    @$el.html @template dropdown:dropdown
