# call with $(el).thingyPicker(items: [item])
# item must be {id: ..., picture: ..., name: ...}
(($)->
  window.ThingyPicker = $.extend (window.ThingyPicker || {}),
    itemToHtml: (contact) ->
      "<div class='item' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"


  ###*
  Main Class for Picker

  @class ThingyPicker
  @constructor
  @param {DomNode} element
  @param {Object} options
  ###
  window.ThingyPicker.ThingyPicker = (element, options) ->
    options ||= {}
    $el = jQueryElement = $(element)
    picker = this
    debug = options.debug || false

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


    this.$el = ->
      jQueryElement

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
      item = new ThingyPicker.ThingyItem(data, picker)
      items.push item

      item.$el().on 'selection-changed', ->
        console.log "triggered"
        updateMaxSelectedMessage()
        updateSelectedCount()

        ###*
        @event selection.changed
        @param {ThingyItem} item
        ###
        picker.$el().trigger('selection.changed', item)


      console.log "item", item
      addItem(item)
    );


    ########################################
    # Add event handlers
    ########################################

    # add selected class to the clicked filter link
    $el.find(".filter-link").click (event)->
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

)(jQuery)