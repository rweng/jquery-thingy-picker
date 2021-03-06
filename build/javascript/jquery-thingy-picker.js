(function() {
  var $, Item, Picker, ThingyPicker, root,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = window;

  $ = root.jQuery;

  if (typeof exports !== 'undefined') {
    ThingyPicker = exports;
  } else {
    ThingyPicker = root.ThingyPicker = {};
  }

  /**
  A Item is a single, selectable item in a ThingyPicker
  
  @class Item
  @constructor
  @param {Object} data
  @param {Object} options
  */


  Item = (function() {
    /**
    @static
    @method itemToHtml
    @param {Object} data
    @return {String} html string
    */
    Item.itemToHtml = function(contact) {
      return "<div class='item' id='" + contact.id + "'><img src='" + contact.picture + "'/><div class='item-name'>" + contact.name + "</div></div>";
    };

    Item.EVENTS = {
      /**
      @event selection-changed
      */

      SELECTION_CHANGED: 'selection-changed'
    };

    Item.SELECTED_CLASS = 'selected';

    function Item(data, options) {
      var _this = this;

      this.data = data;
      this.isSelected = __bind(this.isSelected, this);
      this.select = __bind(this.select, this);
      this.deselect = __bind(this.deselect, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.isVisible = __bind(this.isVisible, this);
      this.toggle = __bind(this.toggle, this);
      this.on = __bind(this.on, this);
      this.canBeSelected = __bind(this.canBeSelected, this);
      this.toJSON = __bind(this.toJSON, this);
      this.itemToHtml = __bind(this.itemToHtml, this);
      if (options) {
        $.extend(this, options);
      }
      this.debug || (this.debug = false);
      this.$el = $(this.itemToHtml(this.data));
      this.$el.data("tp-item", this);
      this.$el.click(function(event) {
        return _this.toggle();
      });
    }

    Item.prototype.itemToHtml = function(data) {
      return Item.itemToHtml(data);
    };

    /**
    this.data
    
    @method toJSON
    @return {Object}
    */


    Item.prototype.toJSON = function() {
      return this.data;
    };

    /**
    true if not overwritten
    
    @method canBeSelected
    @return {Boolean}
    */


    Item.prototype.canBeSelected = function() {
      return true;
    };

    /**
    @method on
    @param {jQuery.Event} event
    @param {Function} handler
    */


    Item.prototype.on = function(event, handler) {
      return this.$el.on(event, handler);
    };

    /**
    selects the item if it is unselected, unselects if it is selected
    
    @method toggle
    @return {Item} this
    */


    Item.prototype.toggle = function() {
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


    Item.prototype.isVisible = function() {
      return this.$el.css('display') !== "none";
    };

    /**
    delegates to $el.show and removes .filtered from $el
    @method show
    */


    Item.prototype.show = function() {
      this.$el.show();
      return this.$el.removeClass('filtered');
    };

    /**
    delegates to $el.hide and adds the class 'filtered' to $el
    @method hide
    */


    Item.prototype.hide = function() {
      this.$el.hide();
      return this.$el.addClass('filtered');
    };

    /**
    @method deselect
    */


    Item.prototype.deselect = function() {
      if (this.debug) {
        console.log("deselect called");
      }
      if (this.isSelected()) {
        this.$el.removeClass(Item.SELECTED_CLASS);
        return this.$el.trigger(Item.EVENTS.SELECTION_CHANGED);
      }
    };

    /**
    Marks this item as selected
    
    @method select
    */


    Item.prototype.select = function() {
      if (this.canBeSelected() && !this.isSelected()) {
        this.$el.addClass(Item.SELECTED_CLASS);
        return this.$el.trigger(Item.EVENTS.SELECTION_CHANGED);
      }
    };

    /**
    @method isSelected
    @return {Boolean}
    */


    Item.prototype.isSelected = function() {
      if (this.debug) {
        console.log("isSelected() in", $el[0]);
      }
      return this.$el.hasClass("selected");
    };

    return Item;

  })();

  ThingyPicker.Item = Item;

  /**
  Main Class for Picker
  
  @class Picker
  @constructor
  @param {DomNode} element
  @param {Object} options
  */


  Picker = (function() {
    Picker.EVENTS = {
      /**
      @event selection.changed
      @param {ThingyItem} item
      */

      SELECTION_CHANGED: 'selection.changed'
    };

    Picker.prototype.baseHtml = function() {
      var html;

      return html = "<div class='thingy-picker'>" + "    <div class='inner-header'>" + ("        <span class='filter-label'>" + this.labels.find_items + "</span><input type='text' placeholder='Start typing a name' class='filter'/>") + ("        <a class='filter-link selected' data-tp-filter='all' href='#'>" + this.labels.all + "</a>") + ("        <a class='filter-link' data-tp-filter='selected' href='#'>" + this.labels.selected + " (<span class='selected-count'>0</span>)</a>") + (this.maxSelected ? "<div class='max-selected-wrapper'></div>" : "") + "    </div>" + "    <div class='items'></div>" + "</div>";
    };

    function Picker(options) {
      this.updateMaxSelectedMessage = __bind(this.updateMaxSelectedMessage, this);
      this.addItem = __bind(this.addItem, this);
      this.maxSelectedEnabled = __bind(this.maxSelectedEnabled, this);
      this.updateVisibleItems = __bind(this.updateVisibleItems, this);
      this.updateSelectedCount = __bind(this.updateSelectedCount, this);
      this.selectedCount = __bind(this.selectedCount, this);
      this.visibleItems = __bind(this.visibleItems, this);
      this.clearSelection = __bind(this.clearSelection, this);
      this.showSelectedItemsOnly = __bind(this.showSelectedItemsOnly, this);
      this.showAllItems = __bind(this.showAllItems, this);
      this.getSelectedItems = __bind(this.getSelectedItems, this);
      this.toJSON = __bind(this.toJSON, this);
      var default_options,
        _this = this;

      default_options = {
        $el: $("<div class='thingy-picker' />"),
        data: function() {
          return [];
        },
        items: [],
        debug: false,
        maxSelected: false,
        isItemPreselected: function(item) {
          return false;
        }
      };
      $.extend(this, default_options, options || {});
      this.$el.data('instance', this);
      if (!String.prototype.trim) {
        String.prototype.trim = function() {
          return this.replace(/^\s+|\s+$/g, "");
        };
      }
      if (this.$el.html().trim() === '') {
        this.$el.html(this.baseHtml());
      }
      if (this.items.length === 0 && this.data().length > 0) {
        $.each(this.data(), function(i, data) {
          return _this.addItem(new Item(data));
        });
      }
      this.$el.find(".filter-link").click(function(event) {
        event.preventDefault();
        _this.$el.find(".filter-link").removeClass("selected");
        $(event.target).addClass('selected');
        return _this.updateVisibleItems();
      });
      this.$el.find("input.filter").keyup(function() {
        return _this.updateVisibleItems();
      });
      this.updateMaxSelectedMessage();
      this.updateSelectedCount();
    }

    Picker.prototype.labels = {
      selected: "Selected",
      filter_placeholder: "Start typing a name",
      find_items: "Find items:",
      all: "All",
      max_selected_message: "{0} of {1} selected"
    };

    Picker.prototype.toJSON = function() {
      return this.items;
    };

    Picker.prototype.sorter = function(a, b) {
      var x, y, _ref, _ref1;

      x = a.name.toLowerCase();
      y = b.name.toLowerCase();
      return (_ref = x < y) != null ? _ref : -{
        1: (_ref1 = x > y) != null ? _ref1 : {
          1: 0
        }
      };
    };

    Picker.prototype.isItemFiltered = function(item) {
      var $inputFilter, linkFilter;

      $inputFilter = this.$el.find("input.filter");
      if ($inputFilter.length === 1) {
        if (!new RegExp($inputFilter.val(), "i").test(item.data.name)) {
          return true;
        }
      }
      linkFilter = this.$el.find('.filter-link.selected').data('tp-filter');
      if (linkFilter === "selected" && !item.isSelected()) {
        return true;
      }
      return false;
    };

    /**
    @method getSelectedItems
    */


    Picker.prototype.getSelectedItems = function() {
      return $.grep(this.items, function(item) {
        return item.isSelected();
      });
    };

    /**
    @method hasMaxSelected
    @return {Boolean}
    */


    Picker.prototype.hasMaxSelected = function() {
      return this.maxSelected > 0;
    };

    /**
    calls show on all items
    
    @method showAllItems
    */


    Picker.prototype.showAllItems = function() {
      var item, _i, _len, _ref, _results;

      _ref = this.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(item.show());
      }
      return _results;
    };

    /**
    hides all items except the selected ones
    
    @method showSelectedItemsOnly
    */


    Picker.prototype.showSelectedItemsOnly = function() {
      var item, _i, _len, _ref, _results;

      _ref = this.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (item.isSelected()) {
          _results.push(item.show());
        } else {
          _results.push(item.hide());
        }
      }
      return _results;
    };

    /**
    deselects all items
    
    @method clearSelection
    @return {[ThingyItem]} changed items
    */


    Picker.prototype.clearSelection = function() {
      var deselected, item, _i, _len, _ref;

      if (this.debug) {
        console.log("in: clearSelection");
      }
      deselected = [];
      _ref = this.items;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (this.debug) {
          console.log("item", item.isSelected());
        }
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


    Picker.prototype.visibleItems = function() {
      return $.grep(this.items, function(item) {
        return item.isVisible();
      });
    };

    Picker.prototype.selectedCount = function() {
      return this.$el.find(".item.selected").length;
    };

    Picker.prototype.updateSelectedCount = function() {
      return this.$el.find(".selected-count").html(this.selectedCount());
    };

    /**
    @method updateVisibleItems
    */


    Picker.prototype.updateVisibleItems = function() {
      var item, _i, _len, _ref, _results;

      _ref = this.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (this.isItemFiltered(item)) {
          _results.push(item.hide());
        } else {
          _results.push(item.show());
        }
      }
      return _results;
    };

    Picker.prototype.maxSelectedEnabled = function() {
      return this.hasMaxSelected();
    };

    /**
    @method addItem
    @param {Item} item
    */


    Picker.prototype.addItem = function(item) {
      var _this = this;

      this.items.push(item);
      if (this.isItemPreselected(item)) {
        item.select();
      }
      item.$el.on(Item.EVENTS.SELECTION_CHANGED, function() {
        if (_this.debug) {
          console.log("triggered");
        }
        _this.updateMaxSelectedMessage();
        _this.updateSelectedCount();
        return _this.$el.trigger(Picker.EVENTS.SELECTION_CHANGED, item);
      });
      return this.$el.find(".items").append(item.$el);
    };

    Picker.prototype.updateMaxSelectedMessage = function() {
      var message;

      message = this.labels.max_selected_message.replace("{0}", this.selectedCount()).replace("{1}", this.maxSelected);
      return $(".max-selected-wrapper").html(message);
    };

    return Picker;

  })();

  window.ThingyPicker.Picker = Picker;

  $.fn.thingyPicker = function(options) {
    var picker;

    picker = function($el, options) {
      var obj;

      if ($el.data('thingyPicker')) {
        return $el.data('thingyPicker');
      }
      obj = new Picker($.extend(options, {
        $el: $el
      }));
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

}).call(this);
