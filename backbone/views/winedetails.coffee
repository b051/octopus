window.WineView = Backbone.View.extend
  initialize: ->
    @render()

  render: ->
    $(@el).html @template(@model.toJSON())
    this

  events:
    change: "change"
    "click .save": "beforeSave"
    "click .delete": "deleteWine"
    "drop #picture": "dropHandler"
  
  change: (event) ->
    @hideAlert()
    
    # Apply the change to the model
    target = event.target
    change = {}
    change[target.name] = target.value
    @model.set change
    
    # Run validation rule (if any) on changed item
    if not @model.isValid()
      errors = @model.validationError
      if errors[target.id]
        @addValidationError target.id errors[target.id]

  beforeSave: ->
    if not @model.isValid()
      @displayValidationErrors @model.validationError
      return false
    @saveWine()
    false

  saveWine: ->
    console.log "before save"
    @model.save null,
      success: (model) =>
        @render()
        app.navigate "wines/#{model.id}", false
        @showAlert "Success!", "Wine saved successfully", "alert-success"

      error: ->
        @showAlert "Error", "An error occurred while trying to delete this item", "alert-error"

  deleteWine: ->
    @model.destroy success: ->
      alert "Wine deleted successfully"
      window.history.back()

    false

  dropHandler: (event) ->
    event.stopPropagation()
    event.preventDefault()
    e = event.originalEvent
    e.dataTransfer.dropEffect = "copy"
    @pictureFile = e.dataTransfer.files[0]
    
    # Read the image file from the local file system and display it in the img tag
    reader = new FileReader()
    reader.onloadend = ->
      $("#picture").attr "src", reader.result

    reader.readAsDataURL @pictureFile
  
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
    @$(".alert")
    .removeClass("alert-error alert-warning alert-success alert-info")
    .addClass(klass)
    .html("<strong>#{title}</strong> #{text}")
    .show()

  hideAlert: ->
    @$(".help-inline").html ''
    @$('.error').removeClass 'error'
    @$(".alert").hide()
