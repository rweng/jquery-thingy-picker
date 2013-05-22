(function() {
  describe('Item', function() {
    var data, item;

    item = void 0;
    data = {
      id: 1,
      name: "John Doe",
      picture: "http://placehold.it/50x50"
    };
    beforeEach(function() {
      return item = new ThingyPicker.Item(data);
    });
    it('should call toggle if $el is clicked', function() {
      spyOn(item, 'toggle');
      item.$el.trigger("click");
      return expect(item.toggle).toHaveBeenCalled();
    });
    describe('overloading with options', function() {
      return describe('this', function() {
        return it('should be the item', function() {
          item = new ThingyPicker.Item(data, {
            someMethod: function() {
              return this;
            }
          });
          return expect(item.someMethod()).toEqual(item);
        });
      });
    });
    describe('constructor', function() {
      return describe('item to html', function() {
        it('tries options.itemToHtml first', function() {
          item = new ThingyPicker.Item({
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
        return it('defaults to Item.itemToHtml', function() {
          var original;

          original = ThingyPicker.Item.itemToHtml;
          ThingyPicker.Item.itemToHtml = function() {
            return "<div id='bla' />";
          };
          try {
            item = new ThingyPicker.Item({
              id: 1,
              name: "John Doe",
              picture: "http://placehold.it/50x50"
            });
            return expect(item.$el.attr("id")).toBe("bla");
          } finally {
            ThingyPicker.Item.itemToHtml = original;
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
