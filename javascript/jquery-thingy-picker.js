(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($) {
    var ThingyPicker;

    ThingyPicker = function(element, options) {
      var all_friends, arrayToObjectGraph, buffer, container, elem, excluded_friends_graph, friend_container, friends_per_row, init, lastSelected, maxSelectedEnabled, obj, preselectedFriends, preselected_friends_graph, selectedClass, selectedCount, settings, sortedFriendData, updateMaxSelectedMessage;

      friends_per_row = 0;
      elem = $(element);
      obj = this;
      settings = $.extend({
        max_selected: -1,
        max_selected_message: "{0} of {1} selected",
        pre_selected_friends: [],
        exclude_friends: [],
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
          filter_title: "Find Friends:",
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
      init = function() {
        var all_friends, first_element_offset_px, friend_height_px, getViewportHeight, i, updateSelectedCount, _i, _ref;

        all_friends = $(".jfmfs-friend", elem);
        first_element_offset_px = all_friends.first().offset().top;
        for (i = _i = 0, _ref = all_friends.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if ($(all_friends[i]).offset().top === first_element_offset_px) {
            friends_per_row++;
          } else {
            friend_height_px = $(all_friends[i]).offset().top - first_element_offset_px;
            break;
          }
        }
        elem.delegate(".jfmfs-friend", 'click', function(event) {
          var aFriend, alreadySelected, end, isMaxSelected, isSelected, lastIndex, onlyOne, selIndex, start, _j;

          onlyOne = settings.max_selected === 1;
          isSelected = $(this).hasClass("selected");
          isMaxSelected = $(".jfmfs-friend.selected").length >= settings.max_selected;
          alreadySelected = friend_container.find(".selected").attr('id') === $(this).attr('id');
          if (!onlyOne && !isSelected && maxSelectedEnabled() && isMaxSelected) {
            return;
          }
          if (onlyOne && !alreadySelected) {
            friend_container.find(".selected").removeClass("selected");
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
                  aFriend = $(all_friends[i]);
                  if (!aFriend.hasClass("hide-non-selected") && !aFriend.hasClass("hide-filtered")) {
                    if (maxSelectedEnabled() && $(".jfmfs-friend.selected").length < settings.max_selected) {
                      $(all_friends[i]).addClass("selected");
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
          all_friends.not(".selected").addClass("hide-non-selected");
          $(".filter-link").removeClass("selected");
          return $(this).addClass("selected");
        });
        $("#jfmfs-filter-all").click(function(event) {
          event.preventDefault();
          all_friends.removeClass("hide-non-selected");
          $(".filter-link").removeClass("selected");
          return $(this).addClass("selected");
        });
        elem.find(".jfmfs-friend:not(.selected)").on('hover', function(ev) {
          if (ev.type === 'mouseover') {
            $(this).addClass("hover");
          }
          if (ev.type === 'mouseout') {
            return $(this).removeClass("hover");
          }
        });
        elem.find("#jfmfs-friend-filter-text").keyup(function() {
          var filter, keyUpTimer;

          filter = $(this).val();
          clearTimeout(keyUpTimer);
          return keyUpTimer = setTimeout(function() {
            if (filter === '') {
              all_friends.removeClass("hide-filtered");
            } else {

            }
            container.find(".friend-name:not(:Contains(" + filter + "))").parent().addClass("hide-filtered");
            return container.find(".friend-name:Contains(" + filter + ")").parent().removeClass("hide-filtered");
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
        return elem.trigger("jfmfs.friendload.finished");
      };
      selectedCount = function() {
        return $(".jfmfs-friend.selected").length;
      };
      maxSelectedEnabled = function() {
        return settings.max_selected > 0;
      };
      updateMaxSelectedMessage = function() {
        var message;

        message = settings.labels.max_selected_message.replace("{0}", selectedCount()).replace("{1}", settings.max_selected);
        return $("#jfmfs-max-selected-wrapper").html(message);
      };
      elem.html("<div id='jfmfs-friend-selector'>" + "    <div id='jfmfs-inner-header'>" + ("        <span class='jfmfs-title'>" + settings.labels.filter_title + " </span><input type='text' id='jfmfs-friend-filter-text' value='" + settings.labels.filter_default + "'/>") + ("        <a class='filter-link selected' id='jfmfs-filter-all' href='#'>" + settings.labels.all + "</a>") + ("        <a class='filter-link' id='jfmfs-filter-selected' href='#'>" + settings.labels.selected + " (<span id='jfmfs-selected-count'>0</span>)</a>") + (settings.max_selected > 0 ? "<div id='jfmfs-max-selected-wrapper'></div>" : "" + "    </div>" + "    <div id='jfmfs-friend-container'></div>" + "</div>"));
      friend_container = elem.find("#jfmfs-friend-container");
      container = elem.find("#jfmfs-friend-selector");
      preselected_friends_graph = arrayToObjectGraph(settings.pre_selected_friends);
      excluded_friends_graph = arrayToObjectGraph(settings.exclude_friends);
      all_friends = 1;
      sortedFriendData = settings.data;
      preselectedFriends = {};
      buffer = [];
      selectedClass = "";
      $.each(settings.data, function(i, friend) {
        var _ref;

        selectedClass = (_ref = friend.id, __indexOf.call(preselected_friends_graph, _ref) >= 0) ? "selected" : "";
        return buffer.push("<div class='jfmfs-friend " + selectedClass + "' id='" + friend.id + "'><img src='" + friend.picture + "'/><div class='friend-name'>" + friend.name + "</div></div>");
      });
      friend_container.append(buffer.join(""));
      return init();
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
          return;
        }
        picker = new ThingyPicker(this, options);
        return element.data("thingyPicker", picker);
      });
    };
  })(jQuery);

}).call(this);
