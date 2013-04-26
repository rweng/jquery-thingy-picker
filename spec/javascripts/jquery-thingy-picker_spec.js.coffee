describe 'jquery-thingy-picker', ->
  window.$el = undefined
  WAIT_TIME = 500

  beforeEach ->
    window.$el = $('<div id="element" />')

    # add a hidden element containing our element to the body, so we can check the css with jquery
    window.$hidden = $('<div id="hidden" style="display: none;" />')
    $hidden.append($el)
    $("body").append($hidden)

  afterEach ->
    $hidden.remove()

  it '#element should be defined', ->
    expect($el.length).toBe(1)

  it 'should be a jquery plugin', ->
    expect($el.thingyPicker).toBeDefined()


  describe 'with 3 items', ->
    beforeEach ->
      $el.thingyPicker({
        items: [{
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
      })

    it 'should contain 3 .items', ->
      expect($el.find(".item").length).toBe(3)


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
            $el.find("#jfmfs-filter-selected").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".items.filter-unselected").length).toBe(1)

        it 'should hide non-selected items', ->
          runs ->
            $el.find(".item:first").trigger('click')
            $el.find("#jfmfs-filter-selected").trigger('click')

          waits WAIT_TIME

          runs ->
            expect($el.find(".item.selected").length).toBe(1)
            expect($el.find(".items.filter-unselected").length).toBe(1)
            expect(visibleItems().length).toBe(1)




