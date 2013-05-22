(function() {
  describe('jquery-thingy-picker', function() {
    var firstItem, itemData, makeThingy, picker;

    itemData = function() {
      return [
        {
          id: 1,
          name: "Item 1",
          picture: "http://placehold.it/50x50"
        }, {
          id: 2,
          name: "Item 2",
          picture: "http://placehold.it/50x100"
        }, {
          id: 3,
          name: "Item 3",
          picture: "http://placehold.it/100x50"
        }
      ];
    };
    window.$el = picker = void 0;
    makeThingy = function($el) {
      $el.thingyPicker({
        debug: true,
        items: itemData()
      });
      return $el;
    };
    firstItem = function() {
      return picker.items()[0];
    };
    beforeEach(function() {
      var post, pre;

      window.$el = $('<div id="element" />');
      window.$hidden = $('<div id="hidden" style="display: none;" />');
      $hidden.append($el);
      $hidden.prepend(pre = makeThingy($('<div id="elementPrepend" />')));
      pre.find('.item:first').addClass('selected');
      $hidden.append(post = makeThingy($('<div id="elementAppend" />')));
      post.find('.item:first').addClass('selected');
      return $("body").append($hidden);
    });
    afterEach(function() {
      return $hidden.remove();
    });
    it('#element is defined', function() {
      return expect($el.length).toBe(1);
    });
    it('is a jquery plugin', function() {
      return expect($el.thingyPicker).toBeDefined();
    });
    describe('with no items', function() {
      return it('initializes correctly', function() {
        return expect($el.thingyPicker({
          debug: true
        })).toBeDefined();
      });
    });
    return describe('with 3 items', function() {
      beforeEach(function() {
        makeThingy($el);
        return picker = $el.thingyPicker();
      });
      describe('the 3 items', function() {
        it('has 3 .item elements', function() {
          return expect($el.find(".item").length).toBe(3);
        });
        return it('has a data-tp-item attribute with ThingyItem instance', function() {
          var foundItems;

          foundItems = [];
          $el.find(".item").each(function(index, obj) {
            return foundItems.push($(obj).data('tp-item').data);
          });
          return expect(foundItems).toEqual(itemData());
        });
      });
      describe('Filtering', function() {
        it('is not filtered by default', function() {
          return expect($el.find(".item.filtered").length).toBe(0);
        });
        it('filters if s.th. is inserted in the filter input', function() {
          $el.find("input.filter").val("2").trigger('keyup');
          return expect(picker.visibleItems().length).toBe(1);
        });
        it('clears the filter if the filter input is cleared', function() {
          $el.find(".item").addClass('filtered');
          $el.find("input.filter").val("").trigger('keyup');
          return expect(picker.visibleItems().length).toBe(3);
        });
        describe('Show Selected link', function() {
          it('hides non-selected items', function() {
            $el.find(".item:first").trigger('click');
            $el.find("[data-tp-filter='selected']").trigger('click');
            expect($el.find(".item.selected").length).toBe(1);
            return expect(picker.visibleItems().length).toBe(1);
          });
          return it('updates the count of items are selected', function() {
            expect($el.find(".selected-count").text()).toBe("0");
            $el.find(".item:first").trigger('click');
            return expect($el.find(".selected-count").text()).toBe("1");
          });
        });
        return describe('Show all link', function() {
          it('shows all items');
          return it('removes .filter-unselected from .items', function() {
            return runs(function() {
              $el.find("[data-tp-action='filterSelected']").trigger('click');
              $el.find("[data-tp-action='filterAll']").trigger('click');
              return expect($el.find(".items.filter-unselected").length).toBe(0);
            });
          });
        });
      });
      describe('Events', function() {
        return describe('selection.changed', function() {
          it('is fired when an element is selected or unselected', function() {
            var item, spy;

            item = $el.find('.item:first').data('tp-item');
            spy = jasmine.createSpy();
            $el.on("selection.changed", spy);
            item.select();
            return expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), item);
          });
          it('is fired when an element is deselected', function() {
            var item, spy;

            item = $el.find('.item:first').data('tp-item');
            item.select();
            spy = jasmine.createSpy();
            $el.on("selection.changed", spy);
            item.deselect();
            return expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), item);
          });
          return it('is fired when the selection is cleared', function() {
            var spy;

            firstItem().select();
            spy = jasmine.createSpy();
            $el.on("selection.changed", spy);
            $el.thingyPicker('clearSelection');
            return expect(spy).toHaveBeenCalledWith(jasmine.any(jQuery.Event), firstItem());
          });
        });
      });
      return describe('Instance Methods / Commands', function() {
        describe('showAllItems', function() {
          return it('call show on all items', function() {
            var item, _i, _j, _len, _len1, _ref, _ref1, _results;

            _ref = picker.items();
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              spyOn(item, 'show');
            }
            picker.showAllItems();
            _ref1 = picker.items();
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              item = _ref1[_j];
              _results.push(expect(item.show).toHaveBeenCalled());
            }
            return _results;
          });
        });
        describe('showSelectedItemsOnly', function() {
          return it('should hide non-selected', function() {
            var item;

            item = $el.find('.item:first').data('tp-item');
            item.select();
            return $el.thingyPicker().showSelectedItemsOnly();
          });
        });
        describe('items', function() {
          return it('returns all items of all instances', function() {
            return expect($el.thingyPicker().items().length).toBe(3);
          });
        });
        describe('getSelectedItems', function() {
          return it('returns the selected items', function() {
            $el.find('.item:first').addClass('selected');
            return expect($el.thingyPicker().getSelectedItems().length).toBe(1);
          });
        });
        describe('visibleItems', function() {
          return it('returns visible items', function() {
            firstItem().hide();
            return expect(picker.visibleItems().length).toBe(2);
          });
        });
        return describe('clearSelection', function() {
          return it('removes .selected from all items and returns changed items', function() {
            var result;

            $el.find('.item:first').addClass('selected');
            expect($el.find(".item.selected").length).toBe(1);
            console.log("thingyPicker() result", $el.thingyPicker());
            result = $el.thingyPicker().clearSelection();
            console.log("result", result);
            expect($el.find(".item.selected").length).toBe(0);
            expect(result.length).toBe(1);
            return expect(result[0]).toBe($el.find('.item:first').data('tp-item'));
          });
        });
      });
    });
  });

}).call(this);
