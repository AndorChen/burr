# steal from https://github.com/silas/liquid-blocks

module Burr
  class BlockDrop < ::Liquid::Drop
    def initialize(block)
      @block = block
    end

    def super
      @block.call_super(@context)
    end
  end

  class BlockTag < ::Liquid::Block
    Syntax = /(\w)+/

    attr_accessor :parent
    attr_reader :name

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @name = $1
      else
        raise Liquid::SyntaxError.new("Syntax Error in 'block' - Valid syntax: block [name]")
      end

      super if tokens
    end

    def render(context)
      context.stack do
        context['block'] = BlockDrop.new(self)

        render_all(@nodelist, context)
      end
    end

    def add_parent(nodelist)
      if parent
        parent.add_parent(nodelist)
      else
        self.parent = BlockTag.new(@tag_name, @name, nil)
        parent.nodelist = nodelist
      end
    end

    def call_super(context)
      if parent
        parent.render(context)
      else
        ''
      end
    end

  end
end

Liquid::Template.register_tag(:block, Burr::BlockTag)
