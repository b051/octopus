App.CalendarView = Parse.View.extend

  className: 'row-fluid calendar-wrapper'

  template: $.template 'content-calendar'
  
  initialize: ->
    @render()
  
  render: ->
    @$el.html @template {}
    date = new Date()
    d = date.getDate()
    m = date.getMonth()
    y = date.getFullYear()
    @calendar = @$('.calendar')
    @fullCalendar = @calendar.fullCalendar.bind @calendar
    options =
      header:
        left: 'month,agendaWeek,agendaDay'
        center: 'title'
        right: 'today prev,next'
    
      selectable: yes
      selectHelper: yes
      editable: yes
    
      events: [
        title: 'All Day Event'
        start: new Date(y, m, 1)
      ,
        title: 'Long Event'
        start: new Date(y, m, d-5)
        end: new Date(y, m, d-2)
      ,
        id: 999
        title: 'Repeating Event'
        start: new Date(y, m, d-3, 16, 0)
        allDay: no
      ,
        title: 'Lunch'
        start: new Date(y, m, d, 12, 0)
        end: new Date(y, m, d, 14, 0)
        allDay: no
      ,
        title: 'Click for Google'
        start: new Date(y, m, 28)
        end: new Date(y, m, 29)
        url: 'http://google.com/'
      ]
      eventBackgroundColor: '#278ccf'
    @fullCalendar options
    $ =>
      setTimeout =>
        @update()
      , 10
    @
  
  update: ->
    @fullCalendar 'render'
    @
  
  events:
    'click .popup .close-pop': 'closeEvent'
    'all' : 'x'
    
  
  x: ->
    console.log 'xxx'
  closeEvent: (event) ->
    $(event.target).parent('.new-event').fadeOut('fast')
