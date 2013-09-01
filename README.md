`attrbagger` Cookbook
=====================

Gets your attributes from your bags.

Somewhat fancy.

## Auto-loading

Inclusion of `recipe[attrbagger::default]` will result in the
`keyspec_string => bag_cascade_string_array` pairs specified in the
`node['attrbagger']['configs']` hash being walked and merged into the
node's attribute precedence level specified via
`node['attrbagger']['precedence_level']`.  An example role using
attrbagger to load application-specific configuration from a base,
custom, and dynamic environment-specific data bag, as well as loading
mail service configuration might look like this:

``` ruby
name 'attrbagger_example'
description 'Attrbagger example role'

default_attributes(
  'deployment_env' => 'demo',
  'attrbagger' => {
    'precedence_level' => 'override',
    'configs' => {
      'example_app' => [
        'data_bag_item[applications::base::example_app]',
        'data_bag_item[applications::example_app]',
        "data_bag_item[applications::config_<%= node['deployment_env'] %>::example_app]"
      ],
      'services::mail' => [
        'data_bag_item[services::mail]'
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
- Load `data_bag_item('applications', 'config_demo')` and merge its `example_app`
hash with `node.default['example_app']`, then assign the result to
`node.override['example_app']`
- Load `data_bag_item('services', 'mail')` and merge the entire data bag
contents (except for builtin attributes like `id` and `chef_type`) with
`node.default['services']['mail']`, then assign the result to
`node.override['services']['mail']`.
