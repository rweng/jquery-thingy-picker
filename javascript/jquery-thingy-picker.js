(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var ThingyItem, ThingyPicker, debug;

    debug = true;
    window.ThingyPicker = {
      itemToHtml: function(contact) {
        return "<div class='item' id='" + contact.id + "'><img src='" + contact.picture + "'/><div class='item-name'>" + contact.name + "</div></div>";
      }
    };
    /**
    A ThingyItem is a single, selectable item in a ThingyPicker
    
    @class ThingyItem
    @constructor
    @param {Object} data
    @param {Object} options
    */

    window.ThingyPicker.ThingyItem = ThingyItem = function(data, options) {
      var $el, EVENTS, SELECTED_CLASS, item;

      this.$el = $el = $(window.ThingyPicker.itemToHtml(data));
      this.data = data;
      item = this;
      options || (options = {});
      $el.data("tp-item", this);
      SELECTED_CLASS = 'selected';
      EVENTS = {
        /**
        @event selection-changed
        */

        SELECTION_CHANGED: 'selection-changed'
      };
      /**
      calls options.canBeSelected or returns true
      
      @method canBeSelected
      @return {Boolean}
      */

      this.canBeSelected = function() {
        if (options.canBeSelected) {
          return options.canBeSelected(item);
        } else {
          return true;
        }
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
      selects the item if it is unselected, unselects if it is selected
      
      @method toggle
      @return {ThingyItem} this
      */

      this.toggle = function() {
        if (this.isSelected()) {
          return this.deselect();
        } else {
          return this.select();
        }
      };
      /**
      @method isVisible
      @return {Boolean}
      */

      this.isVisible = function() {
        return $el.css('display') !== "none";
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
        if (this.canBeSelected() && !this.isSelected()) {
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
        return item.toggle();
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

    window.ThingyPicker.ThingyPicker = ThingyPicker = function(element, options) {
      var $el, addItem, items, lastSelected, maxSelectedEnabled, picker, selectedCount, settings, updateMaxSelectedMessage, updateSelectedCount, updateVisibleItems;

      this.$el = $el = $(element);
      picker = this;
      settings = $.extend({
        debug: false,
        maxSelected: -1,
        preSelectedItems: [],
        excludeItems: [],
        items: [],
        isItemFiltered: function(item, filterText) {
          return !new RegExp(filterText, "i").test(item.data.name);
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
      if (settings.itemToHtml) {
        ThingyPicker.itemToHtml = settings.itemToHtml;
      }
      /**
      @method getSelectedItems
      */

      this.getSelectedItems = function() {
        return $.grep(items, function(item) {
          return item.isSelected();
        });
      };
      /**
      @method hasMaxSelected
      @return {Boolean}
      */

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
      /**
      @method visibleItems
      @return {[ThingyItem]}
      */

      this.visibleItems = function() {
        return $.grep(items, function(item) {
          return item.isVisible();
        });
      };
      updateSelectedCount = function() {
        return $el.find(".selected-count").html(selectedCount());
      };
      selectedCount = function() {
        return $el.find(".item.selected").length;
      };
      /**
      @method updateVisibleItems
      */

      updateVisibleItems = function() {
        var filterLinkSaysShow, filterText, filterTextSaysShow, item, mainFilter, _i, _len, _results;

        filterText = $el.find("input.filter").val();
        mainFilter = $el.find('.filter-link.selected').data('tp-filter');
        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          filterLinkSaysShow = mainFilter === "all" || (mainFilter === "selected" && item.isSelected());
          filterTextSaysShow = !settings.isItemFiltered(item, filterText);
          if (filterLinkSaysShow && filterTextSaysShow) {
            _results.push(item.show());
          } else {
            _results.push(item.hide());
          }
        }
        return _results;
      };
      maxSelectedEnabled = function() {
        return settings.maxSelected > 0;
      };
      addItem = function(item) {
        var _ref;

        $el.find(".items").append(item.$el);
        if (_ref = item.data.id, __indexOf.call(settings.preSelectedItems, _ref) >= 0) {
          return item.select();
        }
      };
      updateMaxSelectedMessage = function() {
        var message;

        message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.maxSelected);
        return $(".max-selected-wrapper").html(message);
      };
      $el.html("<div class='thingy-picker'>" + "    <div class='inner-header'>" + ("        <span class='filter-label'>" + settings.labels.find_items + "</span><input type='text' placeholder='Start typing a name' class='filter'/>") + ("        <a class='filter-link selected' data-tp-filter='all' href='#'>" + settings.labels.all + "</a>") + ("        <a class='filter-link' data-tp-filter='selected' href='#'>" + settings.labels.selected + " (<span class='selected-count'>0</span>)</a>") + (settings.maxSelected > 0 ? "<div class='max-selected-wrapper'></div>" : "") + "    </div>" + "    <div class='items'></div>" + "</div>");
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
      $el.find(".filter-link").click(function(event) {
        if (debug) {
          console.log("filter-link clicked: ", this);
        }
        event.preventDefault();
        $el.find(".filter-link").removeClass("selected");
        $(this).addClass('selected');
        return updateVisibleItems();
      });
      $el.find("input.filter").keyup(function() {
        return updateVisibleItems();
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
