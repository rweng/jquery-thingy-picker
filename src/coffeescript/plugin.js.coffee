$.fn.thingyPicker = (options)->
  # return thingyPicker instance if called without options on one element
  picker = ($el, options) ->
    return $el.data('thingyPicker') if $el.data('thingyPicker')

    obj = new Picker($.extend options, {$el: $el})
    $el.data('thingyPicker', obj)
    obj

  if this.length == 1 and typeof options != "string"
    return picker($(this), options)

  # else return jQuery obj, optionally execute command
  this.map ->
    $this = $(this)
    data = picker($this)

    # if string given: execute command and return jQuery
    if (typeof options == 'string')
      data[options].call($this)
      return this
    else # else return ThingyPicker
      return data