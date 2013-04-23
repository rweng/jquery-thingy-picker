# call with $(el).thingyPicker(data: [bla])
# bla must be {id: ..., picture: ..., name: ...}
(($)->
  ThingyPicker = (element, options) ->

    elem = $(element)
    obj = this
    settings = $.extend({
      max_selected: -1,
      max_selected_message: "{0} of {1} selected",
      pre_selected_friends: [],
      exclude_friends: [],
      sorter: (a, b) ->
        x = a.name.toLowerCase()
        y = b.name.toLowerCase()
        ((x < y) ? -1 : ((x > y) ? 1 : 0))
      , labels: {
        selected: "Selected",
        filter_default: "Start typing a name",
        filter_title: "Find Friends:",
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
    # Private functions
    # ----------+----------+----------+----------+----------+----------+----------+

    init = ->
      all_friends = $(".jfmfs-friend", elem);

      # calculate friends per row
      first_element_offset_px = all_friends.first().offset().top;
      for i in [0...(all_friends.length)]
        if $(all_friends[i]).offset().top == first_element_offset_px
          friends_per_row++
        else
          friend_height_px = $(all_friends[i]).offset().top - first_element_offset_px
          break

      # handle when a friend is clicked for selection
      elem.delegate ".jfmfs-friend", 'click', (event) ->
        onlyOne = settings.max_selected == 1
        isSelected = $(this).hasClass("selected")
        isMaxSelected = $(".jfmfs-friend.selected").length >= settings.max_selected
        alreadySelected = friend_container.find(".selected").attr('id') == $(this).attr('id')

        #if the element is being selected, test if the max number of items have
        #already been selected, if so, just return
        if !onlyOne && !isSelected && maxSelectedEnabled() && isMaxSelected
          return

        # if the max is 1 then unselect the current and select the new
        if onlyOne && !alreadySelected
          friend_container.find(".selected").removeClass("selected")

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
                aFriend = $( all_friends[i] )
                if !aFriend.hasClass("hide-non-selected") && !aFriend.hasClass("hide-filtered")
                  if maxSelectedEnabled() && $(".jfmfs-friend.selected").length < settings.max_selected
                    $( all_friends[i] ).addClass("selected")


        # keep track of last selected, this is used for the shift-select functionality
        lastSelected = $(this)

        # update the count of the total number selected
        updateSelectedCount()

        if( maxSelectedEnabled() )
          updateMaxSelectedMessage()


        elem.trigger("jfmfs.selection.changed", [obj.getSelectedIdsAndNames()]);

      # filter by selected, hide all non-selected
      $("#jfmfs-filter-selected").click (event) ->
        event.preventDefault()

        all_friends.not(".selected").addClass("hide-non-selected")
        $(".filter-link").removeClass("selected")
        $(this).addClass("selected")

      # remove filter, show all
      $("#jfmfs-filter-all").click (event) ->
        event.preventDefault()
        all_friends.removeClass("hide-non-selected")
        $(".filter-link").removeClass("selected")
        $(this).addClass("selected")

      # hover effect on friends
      elem.find(".jfmfs-friend:not(.selected)").on 'hover', (ev) ->
        if (ev.type == 'mouseover')
          $(this).addClass("hover")
        if (ev.type == 'mouseout')
          $(this).removeClass("hover")

      # filter as you type
      elem.find("#jfmfs-friend-filter-text").keyup(->
        filter = $(this).val()
        clearTimeout(keyUpTimer)
        keyUpTimer = setTimeout(->
          if(filter == '')
            all_friends.removeClass("hide-filtered")
          else
          container.find(".friend-name:not(:Contains(" + filter +"))").parent().addClass("hide-filtered")
          container.find(".friend-name:Contains(" + filter +")").parent().removeClass("hide-filtered")
          showImagesInViewPort()
        , 400)
      ).focus( ->
        if $.trim($(this).val()) == 'Start typing a name'
          $(this).val('')
      ).blur( ->
        if($.trim($(this).val()) == '')
          $(this).val('Start typing a name')
      )

      # hover states on the buttons
      elem.find(".jfmfs-button").hover( ->
        $(this).addClass("jfmfs-button-hover")
      , ->
        $(this).removeClass("jfmfs-button-hover")
      )

      # manages lazy loading of images
      getViewportHeight = ->
        height = window.innerHeight # Safari, Opera
        mode = document.compatMode

        if ( (mode || !$.support.boxModel) ) # IE, Gecko
          height = if mode == 'CSS1Compat' then document.documentElement.clientHeight else document.body.clientHeight # Quirks

        return height

      showImagesInViewPort = ->
        container_height_px = friend_container.innerHeight()
        scroll_top_px = friend_container.scrollTop()
        container_offset_px = friend_container.offset().top
        $el = undefined
        top_px = undefined
        elementVisitedCount = 0
        foundVisible = false
        allVisibleFriends = $(".jfmfs-friend:not(.hide-filtered )")

        $.each(allVisibleFriends, (i, $el) ->
          elementVisitedCount++;
          if($el != null)
            $el = $(allVisibleFriends[i])
            top_px = (first_element_offset_px + (friend_height_px * Math.ceil(elementVisitedCount/friends_per_row))) - scroll_top_px - container_offset_px
            if top_px + friend_height_px >= -10 && top_px - friend_height_px < container_height_px  # give some extra padding for broser differences
              $el.data('inview', true)
              $el.trigger('inview', [ true ])
              foundVisible = true
            else
              if(foundVisible)
                return false
        )

      updateSelectedCount = ->
        $("#jfmfs-selected-count").html( selectedCount() )

      friend_container.bind('scroll', $.debounce( 250, showImagesInViewPort ))

      updateMaxSelectedMessage()
      showImagesInViewPort()
      updateSelectedCount()
      elem.trigger("jfmfs.friendload.finished")



    # ----------+----------+----------+----------+----------+----------+----------+
    # Initialization of container
    # ----------+----------+----------+----------+----------+----------+----------+
    elem.html(
      "<div id='jfmfs-friend-selector'>" +
      "    <div id='jfmfs-inner-header'>" +
      "        <span class='jfmfs-title'>" + settings.labels.filter_title + " </span><input type='text' id='jfmfs-friend-filter-text' value='" + settings.labels.filter_default + "'/>" +
      "        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>" + settings.labels.all + "</a>" +
      "        <a class='filter-link' id='jfmfs-filter-selected' href='#'>" + settings.labels.selected + " (<span id='jfmfs-selected-count'>0</span>)</a>" +
      ((settings.max_selected > 0) ? "<div id='jfmfs-max-selected-wrapper'></div>" : "") +
      "    </div>" +
      "    <div id='jfmfs-friend-container'></div>" +
      "</div>"
    )

    friend_container = elem.find("#jfmfs-friend-container")
    container = elem.find("#jfmfs-friend-selector")
    preselected_friends_graph = arrayToObjectGraph(settings.pre_selected_friends)
    excluded_friends_graph = arrayToObjectGraph(settings.exclude_friends)
    all_friends = 1
    sortedFriendData = settings.data
    preselectedFriends = {}
    buffer = []
    selectedClass = ""

    $.each(settings.data, (i, friend) ->
      console.log friend
      selectedClass = if (friend.id in preselected_friends_graph) then "selected" else ""
      buffer.push("<div class='jfmfs-friend #{selectedClass}' id='#{friend.id}'><img src='#{friend.picture}'/><div class='friend-name'>#{friend.name}</div></div>")
    );
    friend_container.append(buffer.join(""))

    init()


  $.fn.thingyPicker = (options)->
      this.each ->
        options = $.extend(
          debug: false
        , options || {})

        if options.debug
          console.log("thingyPicker on: ", this)

        element = $(this)

        # return early if this element already has a plugin instance
        return if element.data('thingyPicker')

        # pass options to plugin constructor
        picker = new ThingyPicker(this, options)

        element.data("thingyPicker", picker)

)(jQuery)