# call with $(el).thingyPicker(items: [item])
# item must be {id: ..., picture: ..., name: ...}
(($)->
  debug = true

  ###*
  A ThingyItem is a single, selectable item in a ThingyPicker

  @class ThingyItem
  @constructor
  ###
  ThingyItem = (data, picker) ->
    this.$el = $el = $(ThingyItem.itemToHtml(data))
    this.picker = picker
    this.data = data
    item = this
    $el.data("tp-item", this)
    SELECTED_CLASS = 'selected'
    EVENTS = {
      ###*
      @event selection-changed
      ###
      SELECTION_CHANGED: 'selection-changed'
    }


    ###*
    @method on
    @param {jQuery.Event} event
    @param {Function} handler
    ###
    this.on = (event, handler) ->
      $el.on(event, handler)



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
      unless item.isSelected()
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
      console.log "clicked"
      #if the element is being selected, test if the max number of items have
      #already been selected, if so, just return
      if picker.hasMaxSelected() and not item.isSelected()
        console.log("returning since picker.MaxSelected reached")
        return

      item.select()

    return this

  ThingyItem.itemToHtml = undefined

  ###*
  Main Class for Picker

  @class ThingyPicker
  @constructor
  @param {DomNode} element
  @param {Object} options
  ###
  ThingyPicker = (element, options) ->
    this.$el = elem = $(element)
    picker = this
    settings = $.extend({
      debug: false
      maxSelected: -1
      preSelectedItems: []
      excludeItems: []
      items: []
      isItemFiltered: ($item, filterText) ->
        itemName = $item.find(".item-name").text()
        not new RegExp(filterText, "i").test(itemName)
      itemToHtml: (contact) ->
        "<div class='item' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"
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
    ThingyItem.itemToHtml = settings.itemToHtml

    # ----------+----------+----------+----------+----------+----------+----------+
    # Public functions
    # ----------+----------+----------+----------+----------+----------+----------+

    this.getSelectedIds = ->
      ids = []
      $.each(elem.find(".item.selected"), (i, item) ->
        ids.push($(item).attr("id"))
      )
      return ids

    this.getSelectedIdsAndNames = ->
      selected = []
      $.each(elem.find(".item.selected"), (i, item) ->
        selected.push( {id: $(item).attr("id"), name: $(item).find(".item-name").text()})
      )
      return selected

    this.getSelectedItems = ->
      elem.find('.item.selected')

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



    # ----------+----------+----------+----------+----------+----------+----------+
    # Private functions
    # ----------+----------+----------+----------+----------+----------+----------+

    updateSelectedCount = ->
      elem.find(".selected-count").html( selectedCount() )

    selectedCount = ->
      elem.find(".item.selected").length

    maxSelectedEnabled = ->
      settings.maxSelected > 0

    # adds a ThingyItem to the ThingyPicker
    addItem = (item) ->
      elem.find(".items").append(item.$el)
      item.select() if item.data.id in settings.preSelectedItems


    updateMaxSelectedMessage = ->
      message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.maxSelected)
      $(".max-selected-wrapper").html( message )

    # initialize html
    elem.html(
      "<div class='thingy-picker'>" +
      "    <div class='inner-header'>" +
      "        <span class='filter-label'>#{settings.labels.find_items}</span><input type='text' class='filter' value='#{settings.labels.filter_placeholder}'/>" +
      "        <a class='filter-link selected' data-tp-action='filterAll' href='#'>#{settings.labels.all}</a>" +
      "        <a class='filter-link' data-tp-action='filterSelected' href='#'>#{settings.labels.selected} (<span class='selected-count'>0</span>)</a>" +
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

    # filter by selected, hide all non-selected
    all_items = $(".item", elem);
    elem.find("[data-tp-action='filterSelected']").click (event) ->
      event.preventDefault()
      elem.find(".items").addClass("filter-unselected")

      all_items.not(".selected").addClass("hide-non-selected")
      $(".filter-link").removeClass("selected")
      $(this).addClass("selected")

    # remove filter, show all
    elem.find("[data-tp-action='filterAll']").click (event) ->
      event.preventDefault()
      elem.find(".items").removeClass("filter-unselected")

      all_items.removeClass("hide-non-selected")
      $(".filter-link").removeClass("selected")
      $(this).addClass("selected")

    # hover effect on items
    elem.find(".item:not(.selected)").on 'hover', (ev) ->
      if (ev.type == 'mouseover')
        $(this).addClass("hover")
      if (ev.type == 'mouseout')
        $(this).removeClass("hover")

    # filter as you type
    elem.find("input.filter").keyup(->
      filter = $(this).val()
      clearTimeout(keyUpTimer)
      keyUpTimer = setTimeout(->
        all_items.each (index, item) ->
          $item = $(item)
          if settings.isItemFiltered($item, filter)
            $item.addClass('filtered')
          else
            $item.removeClass('filtered')
      , 400)
    ).focus( ->
      if $.trim($(this).val()) == 'Start typing a name'
        $(this).val('')
    ).blur( ->
      if($.trim($(this).val()) == '')
        $(this).val('Start typing a name')
    )

    # hover states on the buttons
    elem.find(".button").hover( ->
      $(this).addClass("button-hover")
    , ->
      $(this).removeClass("button-hover")
    )

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