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


  base_html: ->
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

  constructor: (element, options) ->
    default_options =
      # data from which Items are created
      data: []
      # you can also pass in Item instances directly
      items: []
      debug: false
      maxSelected: false
      isItemPreselected: (item) -> false

    $.extend @, default_options, options || {}

    @$el = $(element)

  # initialize html
    @$el.html @base_html()

    # create items
    if @items.length == 0 and @data.length > 0
      $.each @data, (i, data) =>
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

  # ----------+----------+----------+----------+----------+----------+----------+
  # Public functions
  # ----------+----------+----------+----------+----------+----------+----------+

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


  isItemFiltered: (item, filterText) ->
    not new RegExp(filterText, "i").test(item.data.name)

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
    filterText = @$el.find("input.filter").val()
    mainFilter = @$el.find('.filter-link.selected').data('tp-filter')

    for item in @items
      filterLinkSaysShow = mainFilter == "all" or (mainFilter == "selected" and item.isSelected())
      filterTextSaysShow = not @isItemFiltered(item, filterText)
      if filterLinkSaysShow and filterTextSaysShow
        item.show()
      else
        item.hide()

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