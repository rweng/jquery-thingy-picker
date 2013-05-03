(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var ThingyItem, ThingyPicker, debug;

    debug = true;
    /**
    A ThingyItem is a single, selectable item in a ThingyPicker
    
    @class ThingyItem
    @constructor
    */

    ThingyItem = function(data, picker) {
      var $el, EVENTS, SELECTED_CLASS, item;

      this.$el = $el = $(ThingyItem.itemToHtml(data));
      this.picker = picker;
      this.data = data;
      item = this;
      $el.data("tp-item", this);
      SELECTED_CLASS = 'selected';
      EVENTS = {
        /**
        @event selection-changed
        */

        SELECTION_CHANGED: 'selection-changed'
      };
      /**
      @method on
      @param {jQuery.Event} event
      @param {Function} handler
      */

      this.on = function(event, handler) {
        return $el.on(event, handler);
      };
      /**
      delegates to $el.show
      @method show
      */

      this.show = function() {
        return $el.show();
      };
      /**
      delegates to $el.hide
      @method hide
      */

      this.hide = function() {
        return $el.hide();
      };
      /**
      @method deselect
      */

      this.deselect = function() {
        if (debug) {
          console.log("deselect called");
        }
        if (item.isSelected()) {
          $el.removeClass(SELECTED_CLASS);
          return $el.trigger(EVENTS.SELECTION_CHANGED);
        }
      };
      /**
      Marks this item as selected
      
      @method select
      */

      this.select = function() {
        if (!item.isSelected()) {
          $el.addClass(SELECTED_CLASS);
          return $el.trigger(EVENTS.SELECTION_CHANGED);
        }
      };
      /**
      @method isSelected
      @return {Boolean}
      */

      this.isSelected = function() {
        if (debug) {
          console.log("isSelected() in", $el[0]);
        }
        return $el.hasClass("selected");
      };
      $el.click(function(event) {
        console.log("clicked");
        if (picker.hasMaxSelected() && !item.isSelected()) {
          console.log("returning since picker.MaxSelected reached");
          return;
        }
        return item.select();
      });
      return this;
    };
    ThingyItem.itemToHtml = void 0;
    /**
    Main Class for Picker
    
    @class ThingyPicker
    @constructor
    @param {DomNode} element
    @param {Object} options
    */

    ThingyPicker = function(element, options) {
      var addItem, all_items, elem, items, lastSelected, maxSelectedEnabled, picker, selectedCount, settings, updateMaxSelectedMessage, updateSelectedCount;

      this.$el = elem = $(element);
      picker = this;
      settings = $.extend({
        debug: false,
        maxSelected: -1,
        preSelectedItems: [],
        excludeItems: [],
        items: [],
        isItemFiltered: function($item, filterText) {
          var itemName;

          itemName = $item.find(".item-name").text();
          return !new RegExp(filterText, "i").test(itemName);
        },
        itemToHtml: function(contact) {
          return "<div class='item' id='" + contact.id + "'><img src='" + contact.picture + "'/><div class='item-name'>" + contact.name + "</div></div>";
        },
        sorter: function(a, b) {
          var x, y, _ref, _ref1;

          x = a.name.toLowerCase();
          y = b.name.toLowerCase();
          return (_ref = x < y) != null ? _ref : -{
            1: (_ref1 = x > y) != null ? _ref1 : {
              1: 0
            }
          };
        },
        labels: {
          selected: "Selected",
          filter_placeholder: "Start typing a name",
          find_items: "Find items:",
          all: "All",
          max_selected_message: "{0} of {1} selected"
        }
      }, options || {});
      items = [];
      lastSelected = void 0;
      ThingyItem.itemToHtml = settings.itemToHtml;
      this.getSelectedIds = function() {
        var ids;

        ids = [];
        $.each(elem.find(".item.selected"), function(i, item) {
          return ids.push($(item).attr("id"));
        });
        return ids;
      };
      this.getSelectedIdsAndNames = function() {
        var selected;

        selected = [];
        $.each(elem.find(".item.selected"), function(i, item) {
          return selected.push({
            id: $(item).attr("id"),
            name: $(item).find(".item-name").text()
          });
        });
        return selected;
      };
      this.getSelectedItems = function() {
        return elem.find('.item.selected');
      };
      this.hasMaxSelected = function() {
        return settings.maxSelected >= picker.getSelectedItems().length;
      };
      /**
      calls show on all items
      
      @method showAllItems
      */

      this.showAllItems = function() {
        var item, _i, _len, _results;

        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          _results.push(item.show());
        }
        return _results;
      };
      /**
      hides all items except the selected ones
      
      @method showSelectedItemsOnly
      */

      this.showSelectedItemsOnly = function() {
        var item, _i, _len, _results;

        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if (item.isSelected()) {
            _results.push(item.show());
          } else {
            _results.push(item.hide());
          }
        }
        return _results;
      };
      /**
      @method items
      @returns {[ThingyItem]} all items
      */

      this.items = function() {
        return items;
      };
      /**
      deselects all items
      
      @method clearSelection
      @return {[ThingyItem]} changed items
      */

      this.clearSelection = function() {
        var deselected, item, _i, _len;

        if (debug) {
          console.log("in: clearSelection");
        }
        deselected = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          console.log("item", item.isSelected());
          if (item.isSelected()) {
            deselected.push(item);
          }
          item.deselect();
        }
        return deselected;
      };
      updateSelectedCount = function() {
        return elem.find(".selected-count").html(selectedCount());
      };
      selectedCount = function() {
        return elem.find(".item.selected").length;
      };
      maxSelectedEnabled = function() {
        return settings.maxSelected > 0;
      };
      addItem = function(item) {
        var _ref;

        elem.find(".items").append(item.$el);
        if (_ref = item.data.id, __indexOf.call(settings.preSelectedItems, _ref) >= 0) {
          return item.select();
        }
      };
      updateMaxSelectedMessage = function() {
        var message;

        message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.maxSelected);
        return $(".max-selected-wrapper").html(message);
      };
      elem.html("<div class='thingy-picker'>" + "    <div class='inner-header'>" + ("        <span class='filter-label'>" + settings.labels.find_items + "</span><input type='text' class='filter' value='" + settings.labels.filter_placeholder + "'/>") + ("        <a class='filter-link selected' data-tp-action='filterAll' href='#'>" + settings.labels.all + "</a>") + ("        <a class='filter-link' data-tp-action='filterSelected' href='#'>" + settings.labels.selected + " (<span class='selected-count'>0</span>)</a>") + (settings.maxSelected > 0 ? "<div class='max-selected-wrapper'></div>" : "") + "    </div>" + "    <div class='items'></div>" + "</div>");
      $.each(settings.items, function(i, data) {
        var item;

        item = new ThingyItem(data, picker);
        items.push(item);
        item.$el.on('selection-changed', function() {
          console.log("triggered");
          updateMaxSelectedMessage();
          updateSelectedCount();
          /**
          @event selection.changed
          @param {ThingyItem} item
          */

          return picker.$el.trigger('selection.changed', item);
        });
        console.log("item", item);
        return addItem(item);
      });
      all_items = $(".item", elem);
      elem.find("[data-tp-action='filterSelected']").click(function(event) {
        event.preventDefault();
        elem.find(".items").addClass("filter-unselected");
        all_items.not(".selected").addClass("hide-non-selected");
        $(".filter-link").removeClass("selected");
        return $(this).addClass("selected");
      });
      elem.find("[data-tp-action='filterAll']").click(function(event) {
        event.preventDefault();
        elem.find(".items").removeClass("filter-unselected");
        all_items.removeClass("hide-non-selected");
        $(".filter-link").removeClass("selected");
        return $(this).addClass("selected");
      });
      elem.find(".item:not(.selected)").on('hover', function(ev) {
        if (ev.type === 'mouseover') {
          $(this).addClass("hover");
        }
        if (ev.type === 'mouseout') {
          return $(this).removeClass("hover");
        }
      });
      elem.find("input.filter").keyup(function() {
        var filter, keyUpTimer;

        filter = $(this).val();
        clearTimeout(keyUpTimer);
        return keyUpTimer = setTimeout(function() {
          return all_items.each(function(index, item) {
            var $item;

            $item = $(item);
            if (settings.isItemFiltered($item, filter)) {
              return $item.addClass('filtered');
            } else {
              return $item.removeClass('filtered');
            }
          });
        }, 400);
      }).focus(function() {
        if ($.trim($(this).val()) === 'Start typing a name') {
          return $(this).val('');
        }
      }).blur(function() {
        if ($.trim($(this).val()) === '') {
          return $(this).val('Start typing a name');
        }
      });
      elem.find(".button").hover(function() {
        return $(this).addClass("button-hover");
      }, function() {
        return $(this).removeClass("button-hover");
      });
      updateMaxSelectedMessage();
      updateSelectedCount();
      return this;
    };
    return $.fn.thingyPicker = function(options) {
      var picker;

      picker = function($el, options) {
        var obj;

        if ($el.data('thingyPicker')) {
          return $el.data('thingyPicker');
        }
        obj = new ThingyPicker($el[0], options);
        $el.data('thingyPicker', obj);
        return obj;
      };
      if (this.length === 1 && typeof options !== "string") {
        return picker($(this), options);
      }
      return this.map(function() {
        var $this, data;

        $this = $(this);
        data = picker($this);
        if (typeof options === 'string') {
          data[options].call($this);
          return this;
        } else {
          return data;
        }
      });
    };
  })(jQuery);

}).call(this);
