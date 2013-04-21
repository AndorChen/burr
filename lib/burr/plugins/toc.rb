module Burr
  class TocPlugin < Plugin

    def after_parse
      parse_toc
    end

    private

    def parse_toc
      item = self.book.current_item

      if item['toc'].size > 0
        # strip title from the parsed content
        #
        first_heading = item['toc'].first
        # only <h1> headings can be the title of the content
        if first_heading['level'] == 1
          # the <h1> heading must be the first line to consider it a title
          item['content'].sub!(/^<h1.*<\/h1>\n+(.*)/, '\1')
          item['title'] = "#{first_heading['title']}"
        end

        item['id'] = "#{item['element']}"
        item['id'] << "-#{item['number']}" unless item['number'].blank?

        # add labels
        #
        current_format_labels = self.book.config['formats']["#{self.book.format}"]['label']['elements']
        current_format_labels = [] if current_format_labels.nil?
        counters = [
          item['number'],
          0,
          0,
          0,
          0,
          0
        ]

        parsed_toc = []

        item['toc'].each do |t|
          level = t['level']
          title = t['title']

          counters[level-1] += 1 if level > 1
          # Reset the counters for the higher heading levels
          (level..5).each { |x| counters[x] = 0 }
          sliced_counters = counters[0..(level-1)]

          parameters = {
            'level'    => level,
            'number'   => item['number'],
            'element'  => item['element'],
            'counters' => sliced_counters
          }

          # format config allows labels for this element type (`labels' option)
          if current_format_labels.include?(item['element']) && level <= self.book.config['formats']["#{self.book.format}"]['label']['deep']
            label = self.book.render_label(item['element'], { 'item' => parameters })
          else
            label = ''
          end

          id = self.book.render_id({ 'item' => parameters })

          parsed_toc << {
            'id'    => id,
            'level' => level,
            'title' => title,
            'label' => label
          }
        end

        item['toc'] = parsed_toc

        item['label'] = item['toc'][0]['label']

        # add labels to content
        #
        item['toc'].each do |tt|
          # the parsed title can be different from the toc entry title
          # that's the case for the titles with markup code inside (* ` ** etc.)
          # thus, the replacement must be done based on a fuzzy title that
          # doesn't include the title text
          fuzzy_title = Regexp.new("<h#{tt['level']}>#{tt['title']}</h#{tt['level']}>")
          labeled_title = sprintf("<h%s id='%s'><span>%s</span>%s</h%s>\n",
                                  tt['level'],
                                  tt['id'],
                                  tt['label'],
                                  '' != tt['label'] ? " #{tt['title']}" : tt['title'],
                                  tt['level']
                                  )
          item['content'].sub!(fuzzy_title, labeled_title)
        end
      end

      # ensure that the item has a title (using the default title if necessary)
      item['title'] = self.book.titles[item['element']] if item['title'].blank?

      nil
    end

  end
end
