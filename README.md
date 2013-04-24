# Introduction

This is a contact-/anything-picker based on [Mike Brevoort's excellent jquery-facebook-multi-friend-selector](https://github.com/mbrevoort/jquery-facebook-multi-friend-selector).

There is a demo at [http://jquery-thingy-picker.herokuapp.com/](http://jquery-thingy-picker.herokuapp.com/).

# Usage

1. Include the css/less and coffeescript/js files in your HTML
2. call `$(selector).thingyPicker({items: items})` on a dom-node. items must be an array in the format `{id: ..., name: ..., picture: ...}`

See the [example/index.html](https://github.com/rweng/jquery-thingy-picker/blob/master/example/index.html) for examples.

## Options:


```js
{
    items: [{id: 1, name: "test", picture: "http://domain.com/pic.png"}]
    debug: true,
    maxSelected: -1,
    preSelectedItems: [],
    excludeItems: [],
    itemToHtml: function(){},
    sorter: function(){},
    isItemFiltered: function(){},
    labels: {} // see jquery-thingy-picker.js
}
```

# Development

Install and start server:

    bundle install
    rvmsudo bundle exec ghost add jquery-thingy-picker.herokuapp.com
    rake serve # for starting the server
    guard # during development

Remove from hosts file:

    rvmsudo bundle exec ghost delete jquery-thingy-picker.herokuapp.com