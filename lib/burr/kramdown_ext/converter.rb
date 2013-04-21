require 'burr/kramdown_ext/parser'
require 'pygments'

module Kramdown
  module Converter
    class Bshtml < Html

      attr_accessor :book

      def initialize(root, options)
        super
        @book = options[:register]
      end

      # Converts paragraph contents image with caption and normal paragraph.
      #
      def convert_p(el, indent)
        if el.children.size == 1 && el.children.first.type == :img && !el.children.first.attr['caption'].nil?
          convert_image_with_caption(el, indent)
        else
          super
        end
      end

      # Converts the codeblock to HTML, using pygments to highlight.
      #
      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr)
        lang = 'text' if lang.blank?

        pyg_opts = {
          :encoding => 'utf-8',
          :cssclass => "highlight type-#{lang}"
        }
        caption = attr['caption']
        file    = attr['file']
        code = ::Pygments.highlight(el.value, :lexer => lang, :options => pyg_opts).chomp << "\n"
        output = '<div class="codeblock'
        output << ' has-caption' if caption
        output << '">'
        if caption
          caption_el = ::Kramdown::Parser::Bsmarkdown.parse(caption).first
          caption_html = inner(caption_el.children.first, 0)
          output << "<p class=\"caption\">#{caption_html}</p>"
        end
        output << "<p class=\"file\"><code>#{file}</code></p>" if file
        output << "#{code}</div>"
      end

      # Converts headers
      #
      def convert_header(el, indent)
        attr = el.attr.dup
        item = self.book.current_item
        if @options[:auto_ids] && !attr['id']
          attr['id'] = generate_id(el.options[:raw_text])
        end
        #@toc << [el.options[:level], attr['id'], el.children] if attr['id'] && in_toc?(el)
        unless attr['class'] == 'skip-toc'
          item['toc'] << {
            'level' => el.options[:level],
            'title' => el.options[:raw_text]
          }
        end

        level = output_header_level(el.options[:level])
        format_as_block_html("h#{level}", attr, inner(el, indent), indent)
      end

      def convert_footnote(el, indent)
        if self.book.format == 'pdf'
          inline = format_as_span_html('span', { 'class'=> 'footnote', 'id' => "fn-#{ el.options[:name] }"}, inner(el.value, 0))
          inline.sub!(/\s*<p>/, '').sub!(/<\/p>\n/, '')
        else
          number = @footnote_counter
          @footnote_counter += 1
          @footnotes << [el.options[:name], el.value]
          "<sup class=\"footnote\" id=\"fnref-#{el.options[:name]}\"><a href=\"#fn-#{el.options[:name]}\" rel=\"footnote\">#{number}</a></sup>"
        end
      end

      ::Kramdown::Parser::Bsmarkdown::BOXES.each do |box|
        define_method("convert_#{box}_box") { |el, indent| <<-EOF }
          #{' '*indent}<div class="#{box} box">\n#{inner(el, indent)}#{' '*indent}</div>\n
        EOF
      end

      alias :orin_convert_table :convert_table

      alias :convert_thead :orin_convert_table
      alias :convert_tbody :orin_convert_table
      alias :convert_tfoot :orin_convert_table
      alias :convert_tr    :orin_convert_table

      def convert_table(el, indent)
        caption = el.attr.delete('caption')
        output = '<div class="table'
        if caption
          caption_el = ::Kramdown::Parser::Bsmarkdown.parse(caption).first
          caption_html = inner(caption_el.children.first, 0)
          output << " has-caption\"><p class=\"caption\">#{caption_html}</p>"
        else
          output << '">'
        end
        output << format_as_indented_block_html(el.type, el.attr, inner(el, indent), indent)
        output << '</div>'
      end

      # Return a HTML ordered list with the footnote content for the used footnotes.
      def footnote_content
        ol = Element.new(:ol)
        ol.attr['start'] = @footnote_start if @footnote_start != 1
        @footnotes.each do |name, data|
          li = Element.new(:li, nil, {'id' => "fn-#{name}"})
          li.children = Marshal.load(Marshal.dump(data.children))
          ol.children << li

          ref = Element.new(:raw, "<a href=\"#fnref-#{name}\" rel=\"reference\">&#8617;</a>")
          if li.children.last.type == :p
            para = li.children.last
          else
            li.children << (para = Element.new(:p))
          end
          para.children << ref
        end
        (ol.children.empty? ? '' : format_as_indented_block_html('div', {:class => "footnotes"}, convert(ol, 2), 0))
      end

      private

      def convert_image_with_caption(el, indent)
        img_el = el.children.first
        caption = img_el.attr.delete('caption')
        img_html = convert_img(img_el, indent)

        caption_el = ::Kramdown::Parser::Bsmarkdown.parse(caption).first
        caption_html = inner(caption_el.children.first, 0)

        "<div class=\"figure\">#{img_html}<p class=\"caption\">#{caption_html}</p></div>"
      end

    end
  end
end
