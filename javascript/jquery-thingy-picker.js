(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    /**
    A ThingyItem is a single, selectable item in a ThingyPicker
    
    @class ThingyItem
    @constructor
    */

    var ThingyItem, ThingyPicker;

    ThingyItem = function(data, picker) {
      var $el, item;

      this.$el = $el = $(ThingyItem.itemToHtml(data));
      this.picker = picker;
      this.data = data;
      item = this;
      $el.data("tp-item", this);
      this.on = function(event, handler) {
        return $el.on(event, handler);
      };
      this.select = function() {
        console.log($el.hasClass("selected"));
        if (!item.isSelected()) {
          console.log("selection");
          $el.addClass('selected');
          return $el.trigger('selection-changed');
        }
      };
      /**
      @method isSelected
      @return {Boolean}
      */

      this.isSelected = function() {
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
    ThingyPicker = function(element, options) {
      var addItem, all_items, buffer, container, elem, item_container, lastSelected, maxSelectedEnabled, picker, selectedClass, selectedCount, settings, updateMaxSelectedMessage, updateSelectedCount;

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
      this.allItems = function() {
        return elem.find('.item');
      };
      this.clearSelected = function() {
        picker.allItems().removeClass("selected");
        return elem;
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
      item_container = elem.find(".items");
      container = elem.find(".thingy-picker");
      buffer = [];
      selectedClass = "";
      $.each(settings.items, function(i, data) {
        var item;

        item = new ThingyItem(data, picker);
        item.$el.on('selection-changed', function() {
          updateMaxSelectedMessage();
          updateSelectedCount();
          return picker.$el.trigger('jfmfs.selection.changed', item);
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
      elem.trigger("jfmfs.itemload.finished");
      return this;
    };
    return $.fn.thingyPicker = function(option) {
      return this.map(function() {
        var $this, data;

        $this = $(this);
        data = $this.data('thingyPicker');
        if (!data) {
          $this.data('thingyPicker', data = new ThingyPicker(this, option));
          return this;
        } else if (typeof option === 'string') {
          return data[option].call($this);
        } else {
          console.log("you should call thingyPicker with initializer or command");
          return this;
        }
      });
    };
  })(jQuery);

}).call(this);
