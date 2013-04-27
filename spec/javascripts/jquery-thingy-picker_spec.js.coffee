describe 'jquery-thingy-picker', ->
  window.$el = undefined
  WAIT_TIME = 500

  items = ->
    [{
      id: 1,
      name: "Item 1",
      picture: "http://placehold.it/50x50"
    },{
      id: 2,
      name: "Item 2",
      picture: "http://placehold.it/50x100"
    },{
      id: 3,
      name: "Item 3",
      picture: "http://placehold.it/100x50"
    }]

  makeThingy = ($el)->
    $el.thingyPicker({
      debug: true
      items: items()
    })
    $el

  beforeEach ->
    window.$el = $('<div id="element" />')

    # add a hidden element containing our element to the body, so we can check the css with jquery
    window.$hidden = $('<div id="hidden" style="display: none;" />')
    $hidden.append($el)

    # add an element just to see if the thingy-picker also works if we have two of them on the page
    # select the first element to make sure that it doesn't effect current
    $hidden.prepend(pre = makeThingy($('<div id="elementPrepend" />')))
    pre.find('.item:first').addClass('selected')
    $hidden.append(post = makeThingy($('<div id="elementAppend" />')))
    post.find('.item:first').addClass('selected')


    $("body").append($hidden)

  afterEach ->
    $hidden.remove()

  it '#element should be defined', ->
    expect($el.length).toBe(1)

  it 'should be a jquery plugin', ->
    expect($el.thingyPicker).toBeDefined()

  describe 'with no items', ->
    it 'should initialize correctly', ->
      expect($el.thingyPicker({debug: true})).toBeDefined()

  describe 'with 3 items', ->
    beforeEach ->
      makeThingy($el)

    describe 'the 3 items', ->
      it 'should exist', ->
        expect($el.find(".item").length).toBe(3)

      it 'should have a data-ts-item attribute with the json', ->
        # can't use map since jQuery adds additional data (like prevobject) to the result
        foundItems = []
        $el.find(".item").each (index, obj) ->
          foundItems.push $(obj).data('ts-item')

        expect(foundItems).toEqual(items())


    describe 'Filtering', ->
      visibleItems = ->
        _.select $el.find('.item'), (i)->
          $(i).css('display') != 'none'

      it 'should not be filtered by default', ->
        expect($el.find(".item.filtered").length).toBe(0)

      it 'should filter if s.th. is inserted in the filter input', ->
        runs ->
          $el.find("input.filter").val("2").trigger('keyup')

        waits WAIT_TIME

        runs ->
          expect($el.find(".item.filtered").length).toBe(2)

      it 'should clear the filter if the filter input is cleared', ->
        runs ->
          $el.find(".item").addClass('filtered')
          $el.find("input.filter").val("").trigger('keyup')

        waits WAIT_TIME

        runs ->
          expect($el.find(".filtered").length).toBe(0)


      describe 'Show Selected link', ->
        it 'should add .filter-unselected to .items', ->
          runs ->
            $el.find("[data-tp-action='filterSelected']").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".items.filter-unselected").length).toBe(1)

        it 'should hide non-selected items', ->
          runs ->
            $el.find(".item:first").trigger('click')
            $el.find("[data-tp-action='filterSelected']").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".item.selected").length).toBe(1)
            expect($el.find(".items.filter-unselected").length).toBe(1)
            expect(visibleItems().length).toBe(1)

        it 'should update the count of items are selected', ->
          runs ->
            expect($el.find(".selected-count").text()).toBe("0")
            $el.find(".item:first").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".selected-count").text()).toBe("1")

      describe 'Show all link', ->
        it 'should show all items'

        it 'should remove .filter-unselected from .items', ->
          runs ->
            $el.find("[data-tp-action='filterSelected']").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".items.filter-unselected").length).toBe(1)
            $el.find("[data-tp-action='filterAll']").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".items.filter-unselected").length).toBe(0)


      describe 'commands', ->
        describe 'allItems', ->
          it 'returns all items of all instances', ->
            expect($el.thingyPicker('allItems')[0].length).toBe(3)

        describe 'getSelectedItems', ->
          it 'returns the selected items', ->
            $el.find('.item:first').addClass('selected')
            expect($el.thingyPicker('getSelectedItems')[0].length).toBe(1)

        describe 'clearSelected', ->
          it 'returns elements', ->
            #expect()

          it 'removes .selected from all items', ->
            $el.find('.item:first').addClass('selected')
            expect($el.find(".item.selected").length).toBe(1)
            $el.thingyPicker("clearSelected")
            expect($el.find(".item.selected").length).toBe(0)



