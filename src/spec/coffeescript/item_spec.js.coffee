describe 'ThingyItem', ->
  item = undefined
  beforeEach ->
    item = new ThingyPicker.ThingyItem({id: 1, name: "John Doe", picture: "http://placehold.it/50x50"})

  it 'should call toggle if $el is clicked', ->
    spyOn(item, 'toggle')

    item.$el.trigger("click")

    expect(item.toggle).toHaveBeenCalled()

  describe '#toggle', ->
    it 'calls select() if deselected', ->
      item.deselect()
      spyOn(item, 'select')

      item.toggle()

      expect(item.select).toHaveBeenCalled()

    it 'calls deselect() if selected', ->
      debugger
      item.select()
      spyOn(item, 'deselect')

      item.toggle()

      expect(item.deselect).toHaveBeenCalled()
