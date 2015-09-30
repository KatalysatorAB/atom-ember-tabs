# ember-tabs package

Makes atom.io work better with Ember pods.

Without `ember-tabs` you end up with a bunch of tabs all named `template.hbs` or `component.js`. This attempts to find tabs in an ember pod structure, and prepends the pod name.

![screenshot](http://i.imgur.com/PAsMJQP.png)

### Pod fuzzy find

Pressing `cmd+shift+m` reveals a fuzzy finder window on the current pods directory, to make it easy to switch between template/component/route/styles etc.

![](http://i.imgur.com/5zvc0Js.png)

## Installation

Search for "ember-tabs" in `Install packages`. You can also find it in the Atom package index:

[https://atom.io/packages/ember-tabs](https://atom.io/packages/ember-tabs)

Or...

### From source

From source:

    git clone https://github.com/KatalysatorAB/atom-ember-tabs.git
    cd atom-ember-tabs
    apm link
