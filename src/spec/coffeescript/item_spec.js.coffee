describe 'Item', ->
  item = undefined
  data = {id: 1, name: "John Doe", picture: "http://placehold.it/50x50"}
  beforeEach ->
    item = new ThingyPicker.Item(data)

  describe '$el', ->
    it 'returns the jquery wrapped element', ->
      expect(item.$el.length).toBe(1)

    it 'has an item instance in data-tp-item', ->
      expect(item.$el.data('tp-item')).toBe(item)

  it 'should call toggle if $el is clicked', ->
    spyOn(item, 'toggle')

    item.$el.trigger("click")

    expect(item.toggle).toHaveBeenCalled()

  describe 'overloading with options', ->
    describe 'this', ->
      it 'should be the item', ->
        item = new ThingyPicker.Item(data, someMethod: -> @)
        expect(item.someMethod()).toEqual(item)

  describe 'constructor', ->
    describe 'item to html', ->
      it 'tries options.itemToHtml first', ->
        item = new ThingyPicker.Item({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"}, {itemToHtml: -> "<div id='ok' />" })
        expect(item.$el.attr("id")).toBe("ok")

      it 'defaults to Item.itemToHtml', ->
        original = ThingyPicker.Item.itemToHtml
        ThingyPicker.Item.itemToHtml = -> "<div id='bla' />"

        try
          item = new ThingyPicker.Item({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"})
          expect(item.$el.attr("id")).toBe("bla")
        finally
          # ensure we reset the global
          ThingyPicker.Item.itemToHtml = original

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

  describe '#show', ->
    beforeEach -> item.hide(); item.show()
    it 'makes $el visible', -> expect(item.isVisible()).toBe(true)
    it 'removes .filtered', -> expect(item.$el.hasClass 'filtered').toBe(false)
  
  describe '#hide', ->
    beforeEach -> item.hide()
    it 'hides the $el', -> expect(item.isVisible()).toBe(false)
    it 'adds the class "filtered" to $el', -> expect(item.$el.hasClass('filtered')).toBe(true)
  
  describe '#isVisible', ->
    it 'returns true if $el is visible', -> expect(item.isVisible()).toBe(true)
    it 'returns false if $el is hidden', ->
      item.$el.hide()
      expect(item.isVisible()).toBe(false)
