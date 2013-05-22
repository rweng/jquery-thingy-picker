(function() {
  describe('ThingyItem', function() {
    var item;

    item = void 0;
    beforeEach(function() {
      return item = new ThingyPicker.ThingyItem({
        id: 1,
        name: "John Doe",
        picture: "http://placehold.it/50x50"
      });
    });
    it('should call toggle if $el is clicked', function() {
      spyOn(item, 'toggle');
      item.$el.trigger("click");
      return expect(item.toggle).toHaveBeenCalled();
    });
    return describe('#toggle', function() {
      it('calls select() if deselected', function() {
        item.deselect();
        spyOn(item, 'select');
        item.toggle();
        return expect(item.select).toHaveBeenCalled();
      });
      return it('calls deselect() if selected', function() {
        debugger;        item.select();
        spyOn(item, 'deselect');
        item.toggle();
        return expect(item.deselect).toHaveBeenCalled();
      });
    });
  });

}).call(this);
