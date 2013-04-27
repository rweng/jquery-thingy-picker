# call with $(el).thingyPicker(items: [item])
# item must be {id: ..., picture: ..., name: ...}
(($)->
  ThingyPicker = (element, options) ->

    items_per_row = 0
    elem = $(element)
    obj = this
    settings = $.extend({
      maxSelected: -1
      preSelectedItems: []
      excludeItems: []
      isItemFiltered: ($item, filterText) ->
        itemName = $item.find(".item-name").text()
        not new RegExp(filterText, "i").test(itemName)
      itemToHtml: (contact) ->
        selectedClass = if (contact.id in this.preSelectedItems) then "selected" else ""
        "<div class='item #{selectedClass}' id='#{contact.id}'><img src='#{contact.picture}'/><div class='item-name'>#{contact.name}</div></div>"
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

    arrayToObjectGraph = (a) ->
      o = {};
      for i in [0...(a.length)]
        o[a[i]]=''
      return o

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

    this.clearSelected = ->
      all_items.removeClass("selected")


# ----------+----------+----------+----------+----------+----------+----------+
    # Private functions
    # ----------+----------+----------+----------+----------+----------+----------+

    init = ->
      all_items = $(".item", elem);

      # handle when a item is clicked for selection
      elem.delegate ".item", 'click', (event) ->
        onlyOne = settings.maxSelected == 1
        isSelected = $(this).hasClass("selected")
        isMaxSelected = $(".item.selected").length >= settings.maxSelected
        alreadySelected = item_container.find(".selected").attr('id') == $(this).attr('id')

        #if the element is being selected, test if the max number of items have
        #already been selected, if so, just return
        if !onlyOne && !isSelected && maxSelectedEnabled() && isMaxSelected
          return

        # if the max is 1 then unselect the current and select the new
        if onlyOne && !alreadySelected
          item_container.find(".selected").removeClass("selected")

        $(this).toggleClass("selected")
        $(this).removeClass("hover")

        # support shift-click operations to select multiple items at a time
        if $(this).hasClass("selected")
          if ( !lastSelected )
            lastSelected = $(this)
          else
            if( event.shiftKey )
              selIndex = $(this).index()
              lastIndex = lastSelected.index()
              end = Math.max(selIndex,lastIndex)
              start = Math.min(selIndex,lastIndex)

              for i in [start...end]
                aitem = $( all_items[i] )
                if !aitem.hasClass("hide-non-selected") && !aitem.hasClass("filtered")
                  if maxSelectedEnabled() && $(".item.selected").length < settings.maxSelected
                    $( all_items[i] ).addClass("selected")


        # keep track of last selected, this is used for the shift-select functionality
        lastSelected = $(this)

        # update the count of the total number selected
        updateSelectedCount()

        if( maxSelectedEnabled() )
          updateMaxSelectedMessage()


        elem.trigger("jfmfs.selection.changed", [obj.getSelectedIdsAndNames()]);

      # filter by selected, hide all non-selected
      elem.find("[data-tp-action='filterSelected']").click (event) ->
        event.preventDefault()
        elem.find(".items").addClass("filter-unselected")

        all_items.not(".selected").addClass("hide-non-selected")
        $(".filter-link").removeClass("selected")
        $(this).addClass("selected")

      # remove filter, show all
      elem.find("#jfmfs-filter-all").click (event) ->
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

      updateSelectedCount = ->
        elem.find("#jfmfs-selected-count").html( selectedCount() )


      updateMaxSelectedMessage()
      updateSelectedCount()
      elem.trigger("jfmfs.itemload.finished")


    selectedCount = ->
      $(".item.selected").length

    maxSelectedEnabled = ->
      settings.maxSelected > 0

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
      "        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>#{settings.labels.all}</a>" +
      "        <a class='filter-link' data-tp-action='filterSelected' id='jfmfs-filter-selected' href='#'>#{settings.labels.selected} (<span id='jfmfs-selected-count'>0</span>)</a>" +
      (if settings.maxSelected > 0 then "<div class='max-selected-wrapper'></div>" else "") +
      "    </div>" +
      "    <div class='items'></div>" +
      "</div>"
    )

    item_container = elem.find(".items")
    container = elem.find(".thingy-picker")
    buffer = []
    selectedClass = ""

    $.each(settings.items, (i, item) ->
      buffer.push settings.itemToHtml(item)
    );

    item_container.append(buffer.join(""))

    init()

    return this

  $.fn.thingyPicker = (options)->
      this.each ->
        options = $.extend(
          debug: false
        , options || {})

        if options.debug
          console.log("thingyPicker on: ", this)

        element = $(this)

        # return early if this element already has a plugin instance
        return element.data('thingyPicker') if element.data('thingyPicker')

        # pass options to plugin constructor
        picker = new ThingyPicker(this, options)

        if options.debug
          console.log "adding thingyPicker to element", element

        element.data("thingyPicker", picker)

)(jQuery)