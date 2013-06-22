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
    Alert.hide()
    
    # Apply the change to the model
    target = event.target
    @model.set target.id, target.value or ''
    
    # Run validation rule (if any) on changed item
    if not @model.isValid()
      errors = @model.validationError
      if errors[target.id]
        Alert.addValidationError target.id, errors[target.id]

  beforeSave: ->
    if not @model.isValid()
      Alert.displayValidationErrors @model.validationError
    else
      @saveWine()
    no

  saveWine: ->
    console.log "before save"
    @model.save null,
      success: (model) =>
        @render()
        app.navigate "wines/#{model.id}", false
        Alert.show "Success!", "Wine saved successfully", "alert-success"

      error: ->
        Alert.show "Error", "An error occurred while trying to delete this item", "alert-error"

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
