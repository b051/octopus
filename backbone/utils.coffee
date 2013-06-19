window.utils =
  
  # Asynchronously load templates located in separate .html files
  loadTemplate: (views, callback) ->
    deferreds = []
    $.each views, (index, view) ->
      if window[view]
        deferreds.push $.get("tpl/#{view}.html", (data) ->
          window[view]::template = _.template(data)
        )
      else
        alert view + " not found"

    $.when.apply(null, deferreds).done callback

  displayValidationErrors: (messages) ->
    for key, message of messages
      @addValidationError key, message
    @showAlert "Warning!", "Fix validation errors and try again", "alert-warning"

  addValidationError: (field, message) ->
    controlGroup = $("##{field}").parent().parent()
    controlGroup.addClass "error"
    $(".help-inline", controlGroup).html message

  removeValidationError: (field) ->
    controlGroup = $("##{field}").parent().parent()
    controlGroup.removeClass "error"
    $(".help-inline", controlGroup).html ""

  showAlert: (title, text, klass) ->
    $(".alert").removeClass "alert-error alert-warning alert-success alert-info"
    $(".alert").addClass klass
    $(".alert").html "<strong>#{title}</strong> #{text}"
    $(".alert").show()

  hideAlert: ->
    $(".help-inline").html ''
    $('.error').removeClass 'error'
    $(".alert").hide()
