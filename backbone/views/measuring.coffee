App.MeasuringView = Parse.View.extend
  className: 'row-fluid form-wrapper'
  
  template: $.template 'form-measuring'
  
  initialize: (@model) ->
  
  render: ->
    @$el.html @template {}
    @$('input:checkbox, input:radio').uniform()
    @$('.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    
    @$('.wysihtml5').wysihtml5
      'font-styles': no
    @$('.select2').chosen()
    
    @
    