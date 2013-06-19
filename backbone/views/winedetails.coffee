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
    
    # Remove any existing alert message
    utils.hideAlert()
    
    # Apply the change to the model
    target = event.target
    change = {}
    change[target.name] = target.value
    @model.set change
    
    # Run validation rule (if any) on changed item
    if not @model.isValid()
      utils.displayValidationErrors @model.validationError

  beforeSave: ->
    if not @model.isValid()
      utils.displayValidationErrors @model.validationError
      return false
    @saveWine()
    false

  saveWine: ->
    console.log "before save"
    @model.save null,
      success: (model) =>
        @render()
        app.navigate "wines/#{model.id}", false
        utils.showAlert "Success!", "Wine saved successfully", "alert-success"

      error: ->
        utils.showAlert "Error", "An error occurred while trying to delete this item", "alert-error"


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
