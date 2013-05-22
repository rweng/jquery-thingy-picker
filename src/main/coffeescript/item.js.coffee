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
  class ThingyItem
    @itemToHtml: (contact) ->
      "<div class='item' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"


    @EVENTS:
      ###*
      @event selection-changed
      ###
      SELECTION_CHANGED: 'selection-changed'

    @SELECTED_CLASS = 'selected'

    constructor:  (@data, @options) ->
      @options ||= {}
      @$el = $(ThingyItem.itemToHtml(data))
      @debug = @options.debug || false
      this.data = data
      self = this
      @$el.data("tp-item", this)


      # handle when a item is clicked for selection
      @$el.click (event) ->
        self.toggle()


    toJSON: ->
      @data

    ###*
    calls options.canBeSelected or returns true

    @method canBeSelected
    @return {Boolean}
    ###
    canBeSelected: ->
      if @options.canBeSelected then @options.canBeSelected(self) else true

    ###*
    @method on
    @param {jQuery.Event} event
    @param {Function} handler
    ###
    on: (event, handler) ->
      @$el.on(event, handler)

    ###*
    selects the item if it is unselected, unselects if it is selected

    @method toggle
    @return {ThingyItem} this
    ###
    toggle: ->
      if @isSelected() then @deselect() else @select()

    ###*
    @method isVisible
    @return {Boolean}
    ###
    isVisible: ->
      @$el.css('display') != "none"


    ###*
    delegates to $el.show
    @method show
    ###
    show: ->
      @$el.show()

    ###*
    delegates to $el.hide
    @method hide
    ###
    hide: ->
      @$el.hide()

    ###*
    @method deselect
    ###
    deselect: ->
      if @debug
        console.log("deselect called")
      if @isSelected()
        @$el.removeClass(ThingyItem.SELECTED_CLASS)
        @$el.trigger(ThingyItem.EVENTS.SELECTION_CHANGED)

    ###*
    Marks this item as selected

    @method select
    ###
    select: ->
      if @canBeSelected() and not @isSelected()
        @$el.addClass(ThingyItem.SELECTED_CLASS)
        @$el.trigger(ThingyItem.EVENTS.SELECTION_CHANGED)

    ###*
    @method isSelected
    @return {Boolean}
    ###
    isSelected: ->
      if @debug
        console.log "isSelected() in", $el[0]
      @$el.hasClass("selected")

  ThingyPicker.ThingyItem = ThingyItem
)()