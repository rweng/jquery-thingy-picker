(->
  root = window
  $ = root.jQuery
  root.ThingyPicker ||= {}

  ###*
  A ThingyItem is a single, selectable item in a ThingyPicker

  @class ThingyItem
  @constructor
  @param {Object} data
  @param {Object} options
  ###
  ThingyItem = ThingyPicker.ThingyItem = (data, options) ->
    $el = $(window.ThingyPicker.itemToHtml(data))
    this.data = data
    self = this
    options ||= {}
    debug = (options || {}).debug || false
    $el.data("tp-item", this)
    SELECTED_CLASS = 'selected'
    EVENTS = {
      ###*
      @event selection-changed
      ###
      SELECTION_CHANGED: 'selection-changed'
    }

    jQueryElement = $el
    this.$el = ->
      jQueryElement

    ###*
    calls options.canBeSelected or returns true

    @method canBeSelected
    @return {Boolean}
    ###
    this.canBeSelected = ->
      if options.canBeSelected then options.canBeSelected(self) else true

    ###*
    @method on
    @param {jQuery.Event} event
    @param {Function} handler
    ###
    this.on = (event, handler) ->
      $el.on(event, handler)

    ###*
    selects the item if it is unselected, unselects if it is selected

    @method toggle
    @return {ThingyItem} this
    ###
    this.toggle = ->
      if @isSelected() then @deselect() else @select()

    ###*
    @method isVisible
    @return {Boolean}
    ###
    this.isVisible = ->
      $el.css('display') != "none"


    ###*
    delegates to $el.show
    @method show
    ###
    this.show = ->
      $el.show()

    ###*
    delegates to $el.hide
    @method hide
    ###
    this.hide = ->
      $el.hide()

    ###*
    @method deselect
    ###
    this.deselect = ->
      if debug
        console.log("deselect called")
      if self.isSelected()
        $el.removeClass(SELECTED_CLASS)
        $el.trigger(EVENTS.SELECTION_CHANGED)

    ###*
    Marks this item as selected

    @method select
    ###
    this.select = ->
      if @canBeSelected() and not @isSelected()
        $el.addClass(SELECTED_CLASS)
        $el.trigger(EVENTS.SELECTION_CHANGED)

    ###*
    @method isSelected
    @return {Boolean}
    ###
    this.isSelected = ->
      if debug
        console.log "isSelected() in", $el[0]
      $el.hasClass("selected")

    # handle when a item is clicked for selection
    $el.click (event) ->
      self.toggle()

    return this

  ThingyItem.itemToHtml = undefined
)()