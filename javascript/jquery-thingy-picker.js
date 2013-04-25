(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var ThingyPicker;

    ThingyPicker = function(element, options) {
      var arrayToObjectGraph, buffer, container, elem, init, item_container, items_per_row, lastSelected, maxSelectedEnabled, obj, selectedClass, selectedCount, settings, updateMaxSelectedMessage;

      items_per_row = 0;
      elem = $(element);
      obj = this;
      settings = $.extend({
        maxSelected: -1,
        preSelectedItems: [],
        excludeItems: [],
        isItemFiltered: function($item, filterText) {
          var itemName;

          itemName = $item.find(".item-name").text();
          return !new RegExp(filterText, "i").test(itemName);
        },
        itemToHtml: function(contact) {
          var selectedClass, _ref;

          selectedClass = (_ref = contact.id, __indexOf.call(this.preSelectedItems, _ref) >= 0) ? "selected" : "";
          return "<div class='item " + selectedClass + "' id='" + contact.id + "'><img src='" + contact.picture + "'/><div class='item-name'>" + contact.name + "</div></div>";
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
      arrayToObjectGraph = function(a) {
        var i, o, _i, _ref;

        o = {};
        for (i = _i = 0, _ref = a.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          o[a[i]] = '';
        }
        return o;
      };
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
      this.clearSelected = function() {
        return all_items.removeClass("selected");
      };
      init = function() {
        var all_items, updateSelectedCount;

        all_items = $(".item", elem);
        elem.delegate(".item", 'click', function(event) {
          var aitem, alreadySelected, end, i, isMaxSelected, isSelected, lastIndex, onlyOne, selIndex, start, _i;

          onlyOne = settings.maxSelected === 1;
          isSelected = $(this).hasClass("selected");
          isMaxSelected = $(".item.selected").length >= settings.maxSelected;
          alreadySelected = item_container.find(".selected").attr('id') === $(this).attr('id');
          if (!onlyOne && !isSelected && maxSelectedEnabled() && isMaxSelected) {
            return;
          }
          if (onlyOne && !alreadySelected) {
            item_container.find(".selected").removeClass("selected");
          }
          $(this).toggleClass("selected");
          $(this).removeClass("hover");
          if ($(this).hasClass("selected")) {
            if (!lastSelected) {
              lastSelected = $(this);
            } else {
              if (event.shiftKey) {
                selIndex = $(this).index();
                lastIndex = lastSelected.index();
                end = Math.max(selIndex, lastIndex);
                start = Math.min(selIndex, lastIndex);
                for (i = _i = start; start <= end ? _i < end : _i > end; i = start <= end ? ++_i : --_i) {
                  aitem = $(all_items[i]);
                  if (!aitem.hasClass("hide-non-selected") && !aitem.hasClass("filtered")) {
                    if (maxSelectedEnabled() && $(".item.selected").length < settings.maxSelected) {
                      $(all_items[i]).addClass("selected");
                    }
                  }
                }
              }
            }
          }
          lastSelected = $(this);
          updateSelectedCount();
          if (maxSelectedEnabled()) {
            updateMaxSelectedMessage();
          }
          return elem.trigger("jfmfs.selection.changed", [obj.getSelectedIdsAndNames()]);
        });
        $("#jfmfs-filter-selected").click(function(event) {
          event.preventDefault();
          all_items.not(".selected").addClass("hide-non-selected");
          $(".filter-link").removeClass("selected");
          return $(this).addClass("selected");
        });
        $("#jfmfs-filter-all").click(function(event) {
          event.preventDefault();
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
        updateSelectedCount = function() {
          return $("#jfmfs-selected-count").html(selectedCount());
        };
        updateMaxSelectedMessage();
        updateSelectedCount();
        return elem.trigger("jfmfs.itemload.finished");
      };
      selectedCount = function() {
        return $(".item.selected").length;
      };
      maxSelectedEnabled = function() {
        return settings.maxSelected > 0;
      };
      updateMaxSelectedMessage = function() {
        var message;

        message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.maxSelected);
        return $(".max-selected-wrapper").html(message);
      };
      elem.html("<div class='thingy-picker'>" + "    <div class='inner-header'>" + ("        <span class='filter-label'>" + settings.labels.find_items + "</span><input type='text' class='filter' value='" + settings.labels.filter_placeholder + "'/>") + ("        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>" + settings.labels.all + "</a>") + ("        <a class='filter-link' id='jfmfs-filter-selected' href='#'>" + settings.labels.selected + " (<span id='jfmfs-selected-count'>0</span>)</a>") + (settings.maxSelected > 0 ? "<div class='max-selected-wrapper'></div>" : "") + "    </div>" + "    <div class='items'></div>" + "</div>");
      item_container = elem.find(".items");
      container = elem.find(".thingy-picker");
      buffer = [];
      selectedClass = "";
      $.each(settings.items, function(i, item) {
        return buffer.push(settings.itemToHtml(item));
      });
      item_container.append(buffer.join(""));
      init();
      return this;
    };
    return $.fn.thingyPicker = function(options) {
      return this.each(function() {
        var element, picker;

        options = $.extend({
          debug: false
        }, options || {});
        if (options.debug) {
          console.log("thingyPicker on: ", this);
        }
        element = $(this);
        if (element.data('thingyPicker')) {
          return element.data('thingyPicker');
        }
        picker = new ThingyPicker(this, options);
        if (options.debug) {
          console.log("adding thingyPicker to element", element);
        }
        return element.data("thingyPicker", picker);
      });
    };
  })(jQuery);

}).call(this);
