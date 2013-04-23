(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var ThingyPicker;

    ThingyPicker = function(element, options) {
      var arrayToObjectGraph, buffer, container, elem, init, item_container, items_per_row, lastSelected, maxSelectedEnabled, obj, preselected_items_graph, selectedClass, selectedCount, settings, updateMaxSelectedMessage;

      items_per_row = 0;
      elem = $(element);
      obj = this;
      settings = $.extend({
        max_selected: -1,
        max_selected_message: "{0} of {1} selected",
        pre_selected_items: [],
        exclude_items: [],
        itemToHtml: function(contact) {
          var selectedClass, _ref;

          selectedClass = (_ref = contact.id, __indexOf.call(this.pre_selected_items, _ref) >= 0) ? "selected" : "";
          return "<div class='jfmfs-item " + selectedClass + "' id='" + contact.id + "'><img src='" + contact.picture + "'/><div class='item-name'>" + contact.name + "</div></div>";
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
          filter_default: "Start typing a name",
          filter_title: "Find items:",
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
        $.each(elem.find(".jfmfs-item.selected"), function(i, item) {
          return ids.push($(item).attr("id"));
        });
        return ids;
      };
      this.getSelectedIdsAndNames = function() {
        var selected;

        selected = [];
        $.each(elem.find(".jfmfs-item.selected"), function(i, item) {
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
        var all_items, first_element_offset_px, getViewportHeight, i, item_height_px, updateSelectedCount, _i, _ref;

        all_items = $(".jfmfs-item", elem);
        first_element_offset_px = all_items.first().offset().top;
        for (i = _i = 0, _ref = all_items.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if ($(all_items[i]).offset().top === first_element_offset_px) {
            items_per_row++;
          } else {
            item_height_px = $(all_items[i]).offset().top - first_element_offset_px;
            break;
          }
        }
        elem.delegate(".jfmfs-item", 'click', function(event) {
          var aitem, alreadySelected, end, isMaxSelected, isSelected, lastIndex, onlyOne, selIndex, start, _j;

          onlyOne = settings.max_selected === 1;
          isSelected = $(this).hasClass("selected");
          isMaxSelected = $(".jfmfs-item.selected").length >= settings.max_selected;
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
                for (i = _j = start; start <= end ? _j < end : _j > end; i = start <= end ? ++_j : --_j) {
                  aitem = $(all_items[i]);
                  if (!aitem.hasClass("hide-non-selected") && !aitem.hasClass("hide-filtered")) {
                    if (maxSelectedEnabled() && $(".jfmfs-item.selected").length < settings.max_selected) {
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
        elem.find(".jfmfs-item:not(.selected)").on('hover', function(ev) {
          if (ev.type === 'mouseover') {
            $(this).addClass("hover");
          }
          if (ev.type === 'mouseout') {
            return $(this).removeClass("hover");
          }
        });
        elem.find("#jfmfs-item-filter-text").keyup(function() {
          var filter, keyUpTimer;

          filter = $(this).val();
          clearTimeout(keyUpTimer);
          return keyUpTimer = setTimeout(function() {
            if (filter === '') {
              all_items.removeClass("hide-filtered");
            } else {

            }
            container.find(".item-name:not(:Contains(" + filter + "))").parent().addClass("hide-filtered");
            return container.find(".item-name:Contains(" + filter + ")").parent().removeClass("hide-filtered");
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
        elem.find(".jfmfs-button").hover(function() {
          return $(this).addClass("jfmfs-button-hover");
        }, function() {
          return $(this).removeClass("jfmfs-button-hover");
        });
        getViewportHeight = function() {
          var height, mode;

          height = window.innerHeight;
          mode = document.compatMode;
          if (mode || !$.support.boxModel) {
            height = mode === 'CSS1Compat' ? document.documentElement.clientHeight : document.body.clientHeight;
          }
          return height;
        };
        updateSelectedCount = function() {
          return $("#jfmfs-selected-count").html(selectedCount());
        };
        updateMaxSelectedMessage();
        updateSelectedCount();
        return elem.trigger("jfmfs.itemload.finished");
      };
      selectedCount = function() {
        return $(".jfmfs-item.selected").length;
      };
      maxSelectedEnabled = function() {
        return settings.max_selected > 0;
      };
      updateMaxSelectedMessage = function() {
        var message;

        message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.max_selected);
        return $("#jfmfs-max-selected-wrapper").html(message);
      };
      elem.html("<div class='jfmfs-item-selector'>" + "    <div id='jfmfs-inner-header'>" + ("        <span class='jfmfs-title'>" + settings.labels.filter_title + " </span><input type='text' id='jfmfs-item-filter-text' value='" + settings.labels.filter_default + "'/>") + ("        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>" + settings.labels.all + "</a>") + ("        <a class='filter-link' id='jfmfs-filter-selected' href='#'>" + settings.labels.selected + " (<span id='jfmfs-selected-count'>0</span>)</a>") + (settings.max_selected > 0 ? "<div id='jfmfs-max-selected-wrapper'></div>" : "" + "    </div>" + "    <div id='jfmfs-item-container'></div>" + "</div>"));
      item_container = elem.find("#jfmfs-item-container");
      container = elem.find(".jfmfs-item-selector");
      preselected_items_graph = arrayToObjectGraph(settings.pre_selected_items);
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
