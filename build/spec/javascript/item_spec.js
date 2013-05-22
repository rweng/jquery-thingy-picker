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
    describe('constructor', function() {
      return describe('item to html', function() {
        it('tries options.itemToHtml first', function() {
          item = new ThingyPicker.ThingyItem({
            id: 1,
            name: "John Doe",
            picture: "http://placehold.it/50x50"
          }, {
            itemToHtml: function() {
              return "<div id='ok' />";
            }
          });
          return expect(item.$el.attr("id")).toBe("ok");
        });
        return it('defaults to ThingyItem.itemToHtml', function() {
          var original;

          original = ThingyPicker.ThingyItem.itemToHtml;
          ThingyPicker.ThingyItem.itemToHtml = function() {
            return "<div id='bla' />";
          };
          try {
            item = new ThingyPicker.ThingyItem({
              id: 1,
              name: "John Doe",
              picture: "http://placehold.it/50x50"
            });
            return expect(item.$el.attr("id")).toBe("bla");
          } finally {
            ThingyPicker.ThingyItem.itemToHtml = original;
          }
        });
      });
    });
    return describe('#toggle', function() {
      it('calls select() if deselected', function() {
        item.deselect();
        spyOn(item, 'select');
        item.toggle();
        return expect(item.select).toHaveBeenCalled();
      });
      return it('calls deselect() if selected', function() {
        item.select();
        spyOn(item, 'deselect');
        item.toggle();
        return expect(item.deselect).toHaveBeenCalled();
      });
    });
  });

}).call(this);
