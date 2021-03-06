module Opal
  module Connect
    module ConnectPlugins
      module HTML
        INDENT = '  '

        TAGS = %w{a button abbr acronym address applet area article aside audio b base basefont bdi
                  bdo big blockquote body br canvas caption center cite code col colgroup command
                  datalist dd del details dfn dialog dir div dl dt em embed fieldset figcaption
                  figure font footer form frame frameset h1 head header hgroup hr html i iframe
                  img input ins kbd keygen label legend li link map mark menu meta meter nav noframes
                  noscript object ol optgroup option output p param pre progress q rp rt ruby s samp
                  script section select small source span strike strong style sub summary sup table tbody
                  td textarea tfoot th thead time title tr track tt u ul var video wbr}

        module InstanceMethods
          def html!(&block)
            HTML::DSL.scope!(self).html!(&block).to_html
          end
        end

        module ClassMethods
          def html!(&block)
            HTML::DSL.scope!(self).html!(&block).to_html
          end
        end

        # http://erikonrails.snowedin.net/?p=379
        class DSL
          def initialize(tag, *args, &block)
            @tag         = tag
            @content     = args.find { |a| a.instance_of? String }
            @attributes  = args.find { |a| a.instance_of? Hash }
            @attr_string = []
            self.instance_eval(&block) if block_given?
          end

          def to_html
            if @tag
              @attr_string << " #{@attributes.map {|k,v| "#{k}=#{v.to_s.inspect}" }.join(" ")}" if @attributes
              "<#{@tag}#{@attr_string.join}>#{@content}#{children.map(&:to_html).join}</#{@tag}>"
            else
              "#{@content}#{children.map(&:to_html).join}"
            end
          end

          def children
            @children ||= []
          end

          # Some of these are Kernel or Object methods or whatever that we need to explicitly override
          [:p, :select].each do |name|
            define_method name do |*args, &block|
              send :method_missing, name, *args, &block
            end
          end

          def method_missing(tag, *args, &block)
            if !TAGS.include?(tag.to_s) && scope.respond_to?(tag, true)
              scope.send(tag, *args, &block)
            else
              child = DSL.scope!(scope).new(tag.to_s, *args, &block)
              children << child
              child
            end
          end

          def scope
            self.class.scope
          end

          class << self
            attr_accessor :scope

            def html! &block
              DSL.scope!(scope).new(nil, nil, &block)
            end

            def scope! scope
              klass = Class.new(self)
              klass.instance_variable_set(:@scope, scope)
              klass
            end
          end
        end
      end

      register_plugin(:html, HTML)
    end
  end
end
