App.MeasuringView = Parse.View.extend
  className: 'row-fluid form-wrapper'
  
  template: $.template 'form-measuring'
  textFieldTemplate: $.template 'widget-form-textfield'
  
  initialize: (@model) ->
  
  render: ->
    textField = (title, options) =>
      @textFieldTemplate title:title, options:options
    
    @$el.html @template textField:textField, model:@model?.toJSON()
    @$('input:checkbox, input:radio').uniform()
    @$('.datepicker').datepicker().on 'changeDate', (event) ->
      $(@).datepicker('hide')
    
    @$('.wysihtml5').wysihtml5
      'font-styles': no
    @$('.select2').chosen()
    @$('input').tooltip()
    @
    