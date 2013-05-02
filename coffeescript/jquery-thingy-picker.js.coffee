# call with $(el).thingyPicker(items: [item])
# item must be {id: ..., picture: ..., name: ...}
(($)->

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

    this.on = (event, handler) ->
      $el.on(event, handler)

    this.select = ->
      console.log $el.hasClass("selected")
      unless item.isSelected()
        console.log("selection")
        $el.addClass('selected')
        $el.trigger('selection-changed')

    ###*
    @method isSelected
    @return {Boolean}
    ###
    this.isSelected = ->
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

    this.allItems = ->
      elem.find('.item')

    this.clearSelected = ->
      picker.allItems().removeClass("selected")
      return elem


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

    # ----------+----------+----------+----------+----------+----------+----------+
    # Initialization of container
    # ----------+----------+----------+----------+----------+----------+----------+
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

    item_container = elem.find(".items")
    container = elem.find(".thingy-picker")
    buffer = []
    selectedClass = ""

    $.each(settings.items, (i, data) ->
      item = new ThingyItem(data, picker)

      item.$el.on 'selection-changed', ->
        updateMaxSelectedMessage()
        updateSelectedCount()

        picker.$el.trigger('jfmfs.selection.changed', item)


      console.log "item", item
      addItem(item)
    );

    all_items = $(".item", elem);

    # filter by selected, hide all non-selected
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
    elem.trigger("jfmfs.itemload.finished")

    return this

  $.fn.thingyPicker = (option)->
    # kinda like bootstrap does it:
    # https://github.com/twitter/bootstrap/blob/master/js/bootstrap-dropdown.js#L134
    this.map ->
      $this = $(this)
      data = $this.data('thingyPicker')

      if !data
        $this.data('thingyPicker', data = new ThingyPicker(this, option))
        return this
      else if (typeof option == 'string')
        data[option].call($this)
      else
        console.log "you should call thingyPicker with initializer or command"
        return this

)(jQuery)