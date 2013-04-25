describe 'jquery-thingy-picker', ->
  $el = undefined
  WAIT_TIME = 500

  beforeEach ->
    $el = $('<div id="#element" />')

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


