`attrbagger` Cookbook
=====================

Gets your attributes from your bags.

Somewhat fancy.

## Auto-loading

Inclusion of `recipe[attrbagger::default]` will result in the "bag
cascade" specified in the `node['attrbagger']['configs']` hash being
walked and merged into the node's attribute precedence level specified
via `node['attrbagger']['precedence_level']`.  An example role using
attrbagger to load application-specific configuration from a base,
custom, and dynamic data bag, as well as loading mail service
configuration might look like this:

``` ruby
name 'attrbagger_example'
description 'Attrbagger example role'

default_attributes(
  'attrbagger' => {
    'precedence_level' => 'override',
    'configs' => {
      'example_app' => [
        'data_bag[applications::base::example_app]',
        'data_bag[applications::example_app]',
        'data_bag[applications::dynamic::example_app]'
      ],
      'mail' => [
        'data_bag[services::mail]'
      ]
    }
  },
  'example_app' => {
    'awesome' => true
  },
  'mail' => {
    'host' => 'localhost',
    'port' => 25
  }
)

run_list(
  'recipe[attrbagger]',
  # ... other stuff
)
```

This would result in the following actions:

- Load `data_bag_item('applications', 'base')` and merge its `example_app`
hash with `node.default['example_app']`, then assign the result to
`node.override['example_app']`
- Load `data_bag_item('applications', 'example_app')` and merge the
entire data bag contents (except for builtin attributes like `id` and
`chef_type`) with `node.default['example_app']`, then assign the result
to `node.override['example_app']`.
- Load `data_bag_item('applications', 'dynamic')` and merge its `example_app`
hash with `node.default['example_app']`, then assign the result to
`node.override['example_app']`
- Load `data_bag_item('services', 'mail')` and merge the entire data bag
contents (except for builtin attributes like `id` and `chef_type`) with
`node.default['mail']`, then assign the result to `node.override['mail']`.
