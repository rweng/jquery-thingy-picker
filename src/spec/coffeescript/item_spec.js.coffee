describe 'ThingyItem', ->
  item = undefined
  beforeEach ->
    item = new ThingyPicker.ThingyItem({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"})

  it 'should call toggle if $el is clicked', ->
    spyOn(item, 'toggle')

    item.$el.trigger("click")

    expect(item.toggle).toHaveBeenCalled()


  describe 'constructor', ->
    describe 'item to html', ->
      it 'tries options.itemToHtml first', ->
        item = new ThingyPicker.ThingyItem({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"}, {itemToHtml: -> "<div id='ok' />" })
        expect(item.$el.attr("id")).toBe("ok")

      it 'defaults to ThingyItem.itemToHtml', ->
        original = ThingyPicker.ThingyItem.itemToHtml
        ThingyPicker.ThingyItem.itemToHtml = -> "<div id='bla' />"

        try
          item = new ThingyPicker.ThingyItem({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"})
          expect(item.$el.attr("id")).toBe("bla")
        finally
          # ensure we reset the global
          ThingyPicker.ThingyItem.itemToHtml = original

  describe '#toggle', ->
    it 'calls select() if deselected', ->
      item.deselect()
      spyOn(item, 'select')

      item.toggle()

      expect(item.select).toHaveBeenCalled()

    it 'calls deselect() if selected', ->
      item.select()
      spyOn(item, 'deselect')

      item.toggle()

      expect(item.deselect).toHaveBeenCalled()
