root = window
$ = root.jQuery

if typeof exports != 'undefined'
  ThingyPicker = exports
else
  ThingyPicker = root.ThingyPicker = {}

###*
A Item is a single, selectable item in a ThingyPicker

@class Item
@constructor
@param {Object} data
@param {Object} options
###
class Item
  ###*
  @static
  @method itemToHtml
  @param {Object} data
  @return {String} html string
  ###
  @itemToHtml: (contact) ->
    "<div class='item' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"


  @EVENTS:
    ###*
    @event selection-changed
    ###
    SELECTION_CHANGED: 'selection-changed'

  @SELECTED_CLASS = 'selected'

  constructor:  (@data, options) ->
    $.extend(@, options) if options

    @debug ||= false
    @$el = $(@itemToHtml(@data))
    @$el.data("tp-item", this)

    # handle when a item is clicked for selection
    @$el.click (event) =>
      @toggle()

  itemToHtml: (data) =>
    Item.itemToHtml(data)

  ###*
  this.data

  @method toJSON
  @return {Object}
  ###
  toJSON: =>
    @data

  ###*
  true if not overwritten

  @method canBeSelected
  @return {Boolean}
  ###
  canBeSelected: =>
    true

  ###*
  @method on
  @param {jQuery.Event} event
  @param {Function} handler
  ###
  on: (event, handler) =>
    @$el.on(event, handler)

  ###*
  selects the item if it is unselected, unselects if it is selected

  @method toggle
  @return {Item} this
  ###
  toggle: =>
    if @isSelected() then @deselect() else @select()

  ###*
  @method isVisible
  @return {Boolean}
  ###
  isVisible: =>
    @$el.css('display') != "none"


  ###*
  delegates to $el.show
  @method show
  ###
  show: =>
    @$el.show()

  ###*
  delegates to $el.hide
  @method hide
  ###
  hide: =>
    @$el.hide()

  ###*
  @method deselect
  ###
  deselect: =>
    if @debug
      console.log("deselect called")
    if @isSelected()
      @$el.removeClass(Item.SELECTED_CLASS)
      @$el.trigger(Item.EVENTS.SELECTION_CHANGED)

  ###*
  Marks this item as selected

  @method select
  ###
  select: =>
    if @canBeSelected() and not @isSelected()
      @$el.addClass(Item.SELECTED_CLASS)
      @$el.trigger(Item.EVENTS.SELECTION_CHANGED)

  ###*
  @method isSelected
  @return {Boolean}
  ###
  isSelected: =>
    if @debug
      console.log "isSelected() in", $el[0]
    @$el.hasClass("selected")

ThingyPicker.Item = Item