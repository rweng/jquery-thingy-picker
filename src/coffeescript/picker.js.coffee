###*
Main Class for Picker

@class Picker
@constructor
@param {DomNode} element
@param {Object} options
###
class Picker
  @EVENTS:
    ###*
    @event selection.changed
    @param {ThingyItem} item
    ###
    SELECTION_CHANGED: 'selection.changed'


  baseHtml: ->
    html =
      "<div class='thingy-picker'>" +
      "    <div class='inner-header'>" +
      "        <span class='filter-label'>#{@labels.find_items}</span><input type='text' placeholder='Start typing a name' class='filter'/>" +
      "        <a class='filter-link selected' data-tp-filter='all' href='#'>#{@labels.all}</a>" +
      "        <a class='filter-link' data-tp-filter='selected' href='#'>#{@labels.selected} (<span class='selected-count'>0</span>)</a>" +
      (if @maxSelected then "<div class='max-selected-wrapper'></div>" else "") +
      "    </div>" +
      "    <div class='items'></div>" +
      "</div>"


  constructor: (options) ->

    default_options =
      $el: $("<div class='thingy-picker' />")
      # data from which Items are created
      data: -> []
      # you can also pass in Item instances directly
      items: []
      debug: false
      maxSelected: false
      isItemPreselected: (item) -> false

    $.extend @, default_options, options || {}

    # put an instance in data-instance
    @$el.data('instance', @)

    # initialize html
    unless String::trim then String::trim = -> @replace /^\s+|\s+$/g, ""
    if @$el.html().trim() == '' then @$el.html @baseHtml() 

    # create items
    if @items.length == 0 and @data().length > 0
      $.each @data(), (i, data) =>
        @addItem(new Item(data))


    ########################################
    # Add event handlers
    ########################################

    # add selected class to the clicked filter link
    @$el.find(".filter-link").click (event) =>
      event.preventDefault()
      @$el.find(".filter-link").removeClass("selected")
      $(event.target).addClass('selected')
      @updateVisibleItems()

    # filter as you type
    @$el.find("input.filter").keyup =>
      @updateVisibleItems()

    @updateMaxSelectedMessage()
    @updateSelectedCount()

  labels:
    selected: "Selected",
    filter_placeholder: "Start typing a name",
    find_items: "Find items:",
    all: "All",
    max_selected_message: "{0} of {1} selected"


  toJSON: =>
    @items

  sorter: (a, b) ->
    x = a.name.toLowerCase()
    y = b.name.toLowerCase()
    ((x < y) ? -1 : ((x > y) ? 1 : 0))


  isItemFiltered: (item) ->
    # test input field filter
    $inputFilter = @$el.find("input.filter")
    if $inputFilter.length == 1
      return true unless new RegExp($inputFilter.val(), "i").test(item.data.name)

    # test links filter
    linkFilter = @$el.find('.filter-link.selected').data('tp-filter')
    return true if linkFilter == "selected" and not item.isSelected()

    # if everything gone through, return not filtered
    return false


  ###*
  @method getSelectedItems
  ###
  getSelectedItems: =>
    $.grep @items, (item) ->
      item.isSelected()


  ###*
  @method hasMaxSelected
  @return {Boolean}
  ###
  hasMaxSelected: ->
    @maxSelected > 0


  ###*
  calls show on all items

  @method showAllItems
  ###
  showAllItems: =>
    for item in @items
      item.show()


  ###*
  hides all items except the selected ones

  @method showSelectedItemsOnly
  ###
  showSelectedItemsOnly: =>
    for item in @items
      if item.isSelected()
        item.show()
      else
        item.hide()

  ###*
  deselects all items

  @method clearSelection
  @return {[ThingyItem]} changed items
  ###
  clearSelection: =>
    console.log "in: clearSelection" if @debug

    deselected = []
    for item in @items
      console.log "item", item.isSelected() if @debug
      deselected.push(item) if item.isSelected()
      item.deselect()

    deselected

  ###*
  @method visibleItems
  @return {[ThingyItem]}
  ###
  visibleItems: =>
    $.grep @items, (item) ->
      item.isVisible()

  selectedCount: =>
    @$el.find(".item.selected").length

  updateSelectedCount: =>
    @$el.find(".selected-count").html( @selectedCount() )



  ###*
  @method updateVisibleItems
  ###
  updateVisibleItems: =>
    for item in @items
      if @isItemFiltered(item) then item.hide() else item.show()

  maxSelectedEnabled: =>
    @hasMaxSelected()

  ###*
  @method addItem
  @param {Item} item
  ###
  addItem: (item) =>
    @items.push item
    item.select() if @isItemPreselected(item)

    item.$el.on Item.EVENTS.SELECTION_CHANGED, =>
      console.log "triggered" if @debug

      @updateMaxSelectedMessage()
      @updateSelectedCount()

      @$el.trigger(Picker.EVENTS.SELECTION_CHANGED, item)

    @$el.find(".items").append(item.$el)

  updateMaxSelectedMessage: =>
    message = @labels.max_selected_message.replace("{0}", @selectedCount()).replace("{1}", @maxSelected)
    $(".max-selected-wrapper").html( message )



window.ThingyPicker.Picker = Picker