describe 'jquery-thingy-picker', ->
  itemData = ->
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

  window.$el = picker = undefined


  makeThingy = ($el)->
    $el.thingyPicker({
      data: itemData
    })
    $el

  firstItem = ->
    picker.items[0]

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


  describe '$el', ->
    beforeEach ->
      picker = new ThingyPicker.Picker
    it 'is the jquery container element', ->
      expect(picker.$el.hasClass('thingy-picker')).toBe(true)

    it 'has the picker in data-instance', ->
      expect(picker.$el.data('instance')).toBe(picker)



  describe 'constructor', ->
    describe 'with no arguments', ->
      it 'should create a div container', ->
        picker = new ThingyPicker.Picker

        expect(picker.$el.is('div.thingy-picker')).toBe(true)

    describe 'with options hash', ->
      it 'should use the provided $el as container', ->
        picker = new ThingyPicker.Picker
          $el: $('<section id="test" />')

        expect(picker.$el.is('section#test')).toBe(true)

  describe '#baseHtml', ->
    it 'determines how an empty picker is rendered', ->
      picker = new ThingyPicker.Picker
        baseHtml: -> "<div id='bla'></div>"
      expect(picker.$el.find('#bla').length).toBe(1)

    it 'if the $el has html, it uses that', ->
      picker = new ThingyPicker.Picker
        $el: $("<div><div id='test' /></div>")

      expect(picker.$el.find('#test').length).toBe(1)


  it '#element is defined', ->
    expect($el.length).toBe(1)

  it 'is a jquery plugin', ->
    expect($el.thingyPicker).toBeDefined()

  describe 'with no items', ->
    it 'initializes correctly', ->
      expect($el.thingyPicker({debug: true})).toBeDefined()

  describe 'with 3 items', ->
    beforeEach ->
      makeThingy($el)
      picker = $el.thingyPicker()

    describe 'the 3 items', ->
      it 'has 3 .item elements', ->
        expect($el.find(".item").length).toBe(3)

      it 'has a data-tp-item attribute with ThingyItem instance', ->
        # can't use map since jQuery adds additional data (like prevobject) to the result
        foundItems = []
        $el.find(".item").each (index, obj) ->
          foundItems.push $(obj).data('tp-item').data

        expect(foundItems).toEqual(itemData())

    describe 'Filtering', ->
      it 'is not filtered by default', ->
        expect($el.find(".item.filtered").length).toBe(0)

      it 'filters if s.th. is inserted in the filter input', ->
        $el.find("input.filter").val("2").trigger('keyup')

        expect(picker.visibleItems().length).toBe(1)

      it 'clears the filter if the filter input is cleared', ->
        $el.find(".item").addClass('filtered')
        $el.find("input.filter").val("").trigger('keyup')

        expect(picker.visibleItems().length).toBe(3)


      describe 'Show Selected link', ->
        it 'hides non-selected items', ->
          $el.find(".item:first").trigger('click')
          $el.find("[data-tp-filter='selected']").trigger('click')

          expect($el.find(".item.selected").length).toBe(1)
          expect(picker.visibleItems().length).toBe(1)

        it 'updates the count of items are selected', ->
          expect($el.find(".selected-count").text()).toBe("0")

          $el.find(".item:first").trigger('click')

          expect($el.find(".selected-count").text()).toBe("1")

      describe 'Show all link', ->
        it 'shows all items'

        it 'removes .filter-unselected from .items', ->          runs ->
          $el.find("[data-tp-action='filterSelected']").trigger('click')

          $el.find("[data-tp-action='filterAll']").trigger('click')

          expect($el.find(".items.filter-unselected").length).toBe(0)


    describe 'Events', ->
      describe 'selection.changed', ->
        it 'is fired when an element is selected or unselected', ->
          item = $el.find('.item:first').data('tp-item')
          spy = jasmine.createSpy()
          $el.on("selection.changed", spy)

          item.select()

          expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), item)

        it 'is fired when an element is deselected', ->
          item = $el.find('.item:first').data('tp-item')
          item.select()
          spy = jasmine.createSpy()
          $el.on("selection.changed", spy)

          item.deselect()

          expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), item)

        it 'is fired when the selection is cleared', ->
          firstItem().select()

          spy = jasmine.createSpy()
          $el.on("selection.changed", spy)

          $el.thingyPicker('clearSelection')

          expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), firstItem())

    describe 'Instance Methods / Commands', ->
      describe 'showAllItems', ->
        it 'call show on all items', ->

          for item in picker.items
            spyOn(item, 'show')

          picker.showAllItems()

          for item in picker.items
            expect(item.show).toHaveBeenCalled()


      describe 'showSelectedItemsOnly', ->
        it 'should hide non-selected', ->
          item = $el.find('.item:first').data('tp-item')
          item.select()

          $el.thingyPicker().showSelectedItemsOnly()

      describe 'items', ->
        it 'returns all items of all instances', ->
          expect($el.thingyPicker().items.length).toBe(3)

      describe 'getSelectedItems', ->
        it 'returns the selected items', ->
          $el.find('.item:first').addClass('selected')
          expect($el.thingyPicker().getSelectedItems().length).toBe(1)

      describe 'visibleItems', ->
        it 'returns visible items', ->
          firstItem().hide()
          expect(picker.visibleItems().length).toBe(2)

      describe 'clearSelection', ->
        it 'removes .selected from all items and returns changed items', ->
          $el.find('.item:first').addClass('selected')

          console.log "thingyPicker() result", $el.thingyPicker()
          result = $el.thingyPicker().clearSelection()
          console.log "result", result

          expect($el.find(".item.selected").length).toBe(0)
          expect(result.length).toBe(1)
          expect(result[0]).toBe($el.find('.item:first').data('tp-item'))




