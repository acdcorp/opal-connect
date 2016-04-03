module Opal
  module Connect
    module ConnectPlugins
      module Events
        $connect_events = ConnectCache.new if RUBY_ENGINE == 'opal'

        module InstanceMethods
          def connect_event_instance_variables(event, _name, _selector)
            # gives you access to this, like jquery
            @this = dom event.current_target
          end
        end

        module ClassMethods
          if RUBY_ENGINE == 'opal'
            def connect_events
              $connect_events[self] ||= []
            end
          end

          attr_accessor :events_dom

          def events_dom(selector = false)
            if selector
              @events_dom = selector
            else
              @events_dom
            end
          end

          def on(name, selector = nil, method = nil, &handler)
            if RUBY_ENGINE == 'opal'
              return if $connect_events_started

              if name.to_s != 'document' && events_dom
                selector = "#{events_dom} #{selector}"
              end

              klass   = self
              handler = proc { |evt| klass.new.__send__(method, evt) } if method
              event   = [klass, name, selector, handler]
              connect_events << event unless connect_events.include? event
            end
          end
        end

        if RUBY_ENGINE == 'opal'
          module ConnectClassMethods
            def teardown_events
              $connect_events.each do |klass, events|
                el = dom('html')

                events.each do |event|
                  _, name, selector, wrapper = event
                  if name.to_s != 'document'
                    el.off(name, selector, &wrapper)
                  else
                    Document.off(selector, &wrapper)
                  end
                end
              end
            end

            def start_events
              $connect_events_started = true
              $connect_events.each do |klass, events|
                el = dom('html')

                events.map! do |event|
                  klass, name, selector, handler = event

                  # we want to create an anonymous class so we can use instance
                  # methods if events are coming from the Connect module.
                  c = klass.name == 'Opal::Connect' \
                    ? Class.new { include Opal::Connect }.new \
                    : klass.new

                  wrapper = ->(e) do
                    c.connect_event_instance_variables(e, name, selector)
                    c.instance_exec(e, &handler)
                  end

                  (name != :document ? el : Document).on(name, selector, &wrapper)

                  [klass, name, selector, wrapper]
                end
              end
            end
          end
        end
      end

      register_plugin(:events, Events)
    end
  end
end
