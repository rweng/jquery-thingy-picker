# Introduction

This is a contact-/anything-picker based on [Mike Brevoort's excellent jquery-facebook-multi-friend-selector](https://github.com/mbrevoort/jquery-facebook-multi-friend-selector).

There is a demo at [http://jquery-thingy-picker.herokuapp.com/](http://jquery-thingy-picker.herokuapp.com/).

Specs are at [http://jquery-thingy-picker.herokuapp.com/jasmine](http://jquery-thingy-picker.herokuapp.com/jasmine).

# Usage

See the [example/index.html](https://github.com/rweng/jquery-thingy-picker/blob/master/example/index.html) for examples.

Before all, include the css/less and coffeescript/js files in your HTML.

## Initialization

Call `$(selector).thingyPicker({items: items})` on a dom-node.
The items must be an array in the format `{id: ..., name: ..., picture: ...}`

## Commands

There are several commands you can use. Commands are invoked via

`$(selector).thingyPicker('command', 'arguments')`

The commands are:

- `allItems`
- `getSelectedItems`
- `clearSelected`


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
    rvmsudo ghost add jquery-thingy-picker.herokuapp.com
    rake serve # for starting the server
    guard # during development

Remove from hosts file:

    rvmsudo ghost delete jquery-thingy-picker.herokuapp.com