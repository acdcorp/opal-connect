# Opal::Connect

This gem connect opal with custom plugins allows to use a set of predefined
plugins as:
  * abilities
  * current_user
  * dom
  * events
  * form
  * html
  * modal
  * pjax
  * rspec
  * scope
  * server
  * store

The goal of this gem is collected implementations of common functionalities
using opal builder to parse Ruby code into Javascript.

It also exposes opal methods to set dom, set elements values (depends of
opal-jquery).

You can also create your own plugins and make them available only for your app.
This helps you to keep your app DRY and share common elements, functions between
ruby classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'opal-connect'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opal-connect

## Usage

#### Initialize

You should add to your boot process a file to setup the opal connect. This
allows you to define what default plugins opal-connect should load and set a path
for your local plugins.

##### How to load plugins

Select the default plugin to load and load your custom plugins here.
The plugin name is the registered name of plugin module name. Normally and
following conventions should be same name of module in downcase and underscore.

```ruby
 # in your initializer file
 # rails
 # config/initializers/opal-connect

 Opal::Connect.setup do
	options[:plugins] do
		server,
		html,
		dom
	end
  end
```

##### Plugins path.

How to set the plugins path?

Add the current directory. Then open the setup block and set the
`plugins_path` to your plugins directory.

```ruby
 Opal.append_path = Dir.pwd
 Opal::Connect.setup do
	options['plugins_path'] = 'app/plugins'
 end
```

##### Livereload

Set the live reload for development scenarios?

This option tells the opal connect to reload files everytime the directories are
reload.

```ruby
 ...
 Opal::Connect.setup do
	options[:livereload] = # true or false
 end
```

##### Scope

The scope option sets the current scope of your application. Normally you should
pass your application class scope.

```ruby
 ...
 Opal::Connect.setup do
	options[:scope] = App.new
 end
```

#### How to create a plugin?

It is possible to add custom plugins. You have to create a module and added to
the `Opal::Connect::ConnectPlugins`.

1. First create a module
```ruby
module Opal::Connect
  module ConnectPlugins
    module CustomPlugin
    end
  end
end
```

2. Validate if the ruby engine is opal and there add the code that is going to
use opal

```ruby
module Opal::Connect
  module ConnectPlugins
    module CustomPlugin
	  if RUBY_ENGINE == 'opal'
	     # code
	  end
    end
  end
end
```

3. Add your opal methods and logic to the `module InstanceMethods`

```ruby
module Opal::Connect
  module ConnectPlugins
    module CustomPlugin
	  if RUBY_ENGINE == 'opal'
		module InstanceMethods
		  # code
		end
	  end
    end
  end
end
```

4. Register your plugin

```ruby
module Opal::Connect
  module ConnectPlugins
    module CustomPlugin
	  if RUBY_ENGINE == 'opal'
		module InstanceMethods
		  # code
		end
	  end
    end
	register_plugin :custom_plugin, CustomPlugin
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/opal-connect/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
