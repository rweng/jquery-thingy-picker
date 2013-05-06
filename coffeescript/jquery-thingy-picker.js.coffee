# call with $(el).thingyPicker(items: [item])
# item must be {id: ..., picture: ..., name: ...}
(($)->
  debug = true
  window.ThingyPicker = {
    itemToHtml: (contact) ->
      "<div class='item' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"
  }

  ###*
  A ThingyItem is a single, selectable item in a ThingyPicker

  @class ThingyItem
  @constructor
  @param {Object} data
  @param {Object} options
  ###
  window.ThingyPicker.ThingyItem = ThingyItem = (data, options) ->
    this.$el = $el = $(window.ThingyPicker.itemToHtml(data))
    this.data = data
    item = this
    options ||= {}
    $el.data("tp-item", this)
    SELECTED_CLASS = 'selected'
    EVENTS = {
      ###*
      @event selection-changed
      ###
      SELECTION_CHANGED: 'selection-changed'
    }

    ###*
    calls options.canBeSelected or returns true

    @method canBeSelected
    @return {Boolean}
    ###
    this.canBeSelected = ->
      if options.canBeSelected then options.canBeSelected(item) else true

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
      if item.isSelected()
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
      item.toggle()

    return this

  ThingyItem.itemToHtml = undefined

  ###*
  Main Class for Picker

  @class ThingyPicker
  @constructor
  @param {DomNode} element
  @param {Object} options
  ###
  window.ThingyPicker.ThingyPicker = ThingyPicker = (element, options) ->
    this.$el = $el = $(element)
    picker = this
    settings = $.extend({
      debug: false
      maxSelected: -1
      preSelectedItems: []
      excludeItems: []
      items: []
      isItemFiltered: (item, filterText) ->
        not new RegExp(filterText, "i").test(item.data.name)
      sorter: (a, b) ->
        x = a.name.toLowerCase()
        y = b.name.toLowerCase()
        ((x < y) ? -1 : ((x > y) ? 1 : 0))
      ,
      labels: {
        selected: "Selected",
        filter_placeholder: "Start typing a name",
        find_items: "Find items:",
        all: "All",
        max_selected_message: "{0} of {1} selected"
      }
    }, options || {})
    items = []

    lastSelected = undefined # used when shift-click is performed to know where to start from to select multiple elements
    ThingyPicker.itemToHtml = settings.itemToHtml if settings.itemToHtml

    # ----------+----------+----------+----------+----------+----------+----------+
    # Public functions
    # ----------+----------+----------+----------+----------+----------+----------+


    ###*
    @method getSelectedItems
    ###
    this.getSelectedItems = ->
      $.grep items, (item) ->
        item.isSelected()


    ###*
    @method hasMaxSelected
    @return {Boolean}
    ###
    this.hasMaxSelected = ->
      settings.maxSelected >= picker.getSelectedItems().length


    ###*
    calls show on all items

    @method showAllItems
    ###
    this.showAllItems = ->
      for item in items
        item.show()



    ###*
    hides all items except the selected ones

    @method showSelectedItemsOnly
    ###
    this.showSelectedItemsOnly = ->
      for item in items
        if item.isSelected()
          item.show()
        else
          item.hide()

    ###*
    @method items
    @returns {[ThingyItem]} all items
    ###
    this.items = ->
      items

    ###*
    deselects all items

    @method clearSelection
    @return {[ThingyItem]} changed items
    ###
    this.clearSelection = ->
      if debug
        console.log "in: clearSelection"
      deselected = []
      for item in items
        console.log "item", item.isSelected()
        deselected.push(item) if item.isSelected()
        item.deselect()

      deselected

    ###*
    @method visibleItems
    @return {[ThingyItem]}
    ###
    this.visibleItems = ->
      $.grep items, (item) ->
        item.isVisible()


    # ----------+----------+----------+----------+----------+----------+----------+
    # Private functions
    # ----------+----------+----------+----------+----------+----------+----------+

    updateSelectedCount = ->
      $el.find(".selected-count").html( selectedCount() )

    selectedCount = ->
      $el.find(".item.selected").length


    ###*
    @method updateVisibleItems
    ###
    updateVisibleItems = ->
      filterText = $el.find("input.filter").val()
      mainFilter = $el.find('.filter-link.selected').data('tp-filter')

      for item in items
        filterLinkSaysShow = mainFilter == "all" or (mainFilter == "selected" and item.isSelected())
        filterTextSaysShow = not settings.isItemFiltered(item, filterText)
        if filterLinkSaysShow and filterTextSaysShow
          item.show()
        else
          item.hide()

    maxSelectedEnabled = ->
      settings.maxSelected > 0

    # adds a ThingyItem to the ThingyPicker
    addItem = (item) ->
      $el.find(".items").append(item.$el)
      item.select() if item.data.id in settings.preSelectedItems


    updateMaxSelectedMessage = ->
      message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.maxSelected)
      $(".max-selected-wrapper").html( message )

    # initialize html
    $el.html(
      "<div class='thingy-picker'>" +
      "    <div class='inner-header'>" +
      "        <span class='filter-label'>#{settings.labels.find_items}</span><input type='text' placeholder='Start typing a name' class='filter'/>" +
      "        <a class='filter-link selected' data-tp-filter='all' href='#'>#{settings.labels.all}</a>" +
      "        <a class='filter-link' data-tp-filter='selected' href='#'>#{settings.labels.selected} (<span class='selected-count'>0</span>)</a>" +
      (if settings.maxSelected > 0 then "<div class='max-selected-wrapper'></div>" else "") +
      "    </div>" +
      "    <div class='items'></div>" +
      "</div>"
    )

    # create items
    $.each(settings.items, (i, data) ->
      item = new ThingyItem(data, picker)
      items.push item

      item.$el.on 'selection-changed', ->
        console.log "triggered"
        updateMaxSelectedMessage()
        updateSelectedCount()

        ###*
        @event selection.changed
        @param {ThingyItem} item
        ###
        picker.$el.trigger('selection.changed', item)


      console.log "item", item
      addItem(item)
    );

    ########################################
    # Add event handlers
    ########################################

    # add selected class to the clicked filter link
    $el.find(".filter-link").click (event)->
      if debug
        console.log "filter-link clicked: ", this
      event.preventDefault()
      $el.find(".filter-link").removeClass("selected")
      $(this).addClass('selected')
      updateVisibleItems()

    # filter as you type
    $el.find("input.filter").keyup ->
      updateVisibleItems()

    updateMaxSelectedMessage()
    updateSelectedCount()

    return this

  $.fn.thingyPicker = (options)->
    # return thingyPicker instance if called without options on one element
    picker = ($el, options) ->
      return $el.data('thingyPicker') if $el.data('thingyPicker')

      obj = new ThingyPicker($el[0], options)
      $el.data('thingyPicker', obj)
      obj

    if this.length == 1 and typeof options != "string"
      return picker($(this), options)


    # else return jQuery obj, optionally execute command
    this.map ->
      $this = $(this)
      data = picker($this)

      # if string given: execute command and return jQuery
      if (typeof options == 'string')
        data[options].call($this)
        return this
      else # else return ThingyPicker
        return data

)(jQuery)