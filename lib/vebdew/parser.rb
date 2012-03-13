require 'htmlentities'

module Vebdew
  class Parser
    attr_reader :header, :body, :footer

    def initialize lines
      @lines = lines
      @header = []
      @body = []
      @footer = []
      @buffer = []
      @attrs = ""
      @flag = Hash.new { |h, k| h[k] = false }

      parse
    end

  protected
    CMD        = /^:(\w+) (.*)$/
    SLIDE      = /^\!SLIDE$/
    ENDSLIDE   = /^\!ENDSLIDE$/
    STACK      = /^\!STACK$/
    ENDSTACK   = /^\!ENDSTACK$/
    SELECTOR   = /^\{:([^\}]+)\}$/
    CURLY_BAR  = /^~{2,}$/
    GRAVE_BAR  = /^`{2,}$/
    SINGLE_BAR = /^-{2,}$/
    DOUBLE_BAR = /^={2,}$/
    SHARP      = /^(#+) (.+)$/
    UL         = /^\* (.+)$/

    def parse
      for raw_line in @lines
        line = raw_line.lstrip

        # special case for no enders
        close_flag :ul if @flag[:ul] and !line.match(UL)

        # special case for blocks
        block_flag = false
        [[:sample, CURLY_BAR], [:code, GRAVE_BAR]].each do |rule, mth|
          if @flag[rule] and !line.match(mth)
            @buffer << raw_line
            block_flag = true
            break
          end
        end
        next if block_flag

        case line
        when CMD
          command $1, $2
        when SLIDE
          close_buffer
          close_flag :slide
          start_flag :slide
        when ENDSLIDE
          close_buffer
          close_flag :slide
        when STACK
          close_buffer
          close_flag :slide
          close_flag :stack
          start_flag :stack
        when ENDSTACK
          close_buffer
          close_flag :slide
          close_flag :stack
        when SELECTOR
          close_buffer
          selector $1
        when CURLY_BAR
          if @flag[:sample]
            @body << @buffer.join
            @buffer.clear
            close_flag :sample
          else
            close_buffer
            start_flag :sample
          end
        when GRAVE_BAR
          if @flag[:code]
            format_indent
            @body << @buffer.join
            @buffer.clear
            close_flag :code
          else
            close_buffer
            start_flag :code
          end
        when SHARP
          level = $1.size
          @body << "<h#{level}#{append}>#{format_content $2}</h#{level}>"
        when SINGLE_BAR
          tagged = @buffer.pop
          close_buffer
          if tagged and !tagged.empty?
            @body << "<h2#{append}>#{format_content tagged.strip}</h2>"
          else
            @body << "<hr#{append}>"
          end
        when DOUBLE_BAR
          tagged = @buffer.pop
          close_buffer
          if tagged and !tagged.empty?
            @body << "<h1#{append}>#{format_content tagged.strip}</h1>"
          end
        when UL
          start_flag :ul unless @flag[:ul]
          @body << "<li#{append}>#{format_content($1)}</li>"
        else
          @buffer << raw_line
        end
      end
      close_buffer
      close_flag :slide
      close_flag :stack
      close_flag :ul
    end

    def command type, body
      case type
      when "title"
        @header << %Q{<title>#{body}</title>}
      when "description"
        @header << %Q{<meta name="description" content="#{body}">}
      when "author"
        @header << %Q{<meta name="author" content="#{body}">}
      when "email"
        @header << %Q{<meta name="email" content="#{body}">}
      when "stylesheet_link_tag"
        body.split(',').each do |href|
          @header << %Q{<link rel="stylesheet" href="#{href.strip}">}
        end
      when "javascript_include_tag"
        body.split(',').each do |href|
          @footer << %Q{<script type="text/javascript" src="#{href.strip}"></script>}
        end
      else
        # TODO: something wrong!
      end
    end

    def close_buffer
      return if @buffer.empty?
      format_buffer
      @body += @buffer
      @buffer.clear
    end

    START_STR = { :slide => "<section$>",
                  :stack => "<section$>",
                  :sample => '<script type="text/x-sample"$>',
                  :code => '<pre$><code><!--',
                  :ul => "<ul$>" }

    def start_flag flag
      str = START_STR[flag].dup
      str['$'] = append
      @body << str
      @flag[flag] = true
    end

    CLOSE_STR = { :slide => "</section>",
                  :stack => "</section>",
                  :sample => "</script>",
                  :code => '--></code></pre>',
                  :ul => "</ul>" }

    def close_flag flag
      @body << CLOSE_STR[flag] if @flag[flag]
      @flag[flag] = false
    end

    SEL_CLASS = /\.([^\.\[#]+)/
    SEL_ID    = /#([^\.\[#]+)/
    SEL_ATTR  = /\[([^\.\]=#]+)=([^\.\]]+)\]/

    def selector str
      klass = str.scan(SEL_CLASS).flatten
      id = str.scan(SEL_ID).flatten
      attrs = str.scan(SEL_ATTR)

      @attrs = ""
      @attrs += %Q{ class="#{klass.join(' ')}"} unless klass.empty?
      @attrs += %Q{ id="#{id.join(' ')}"} unless id.empty?
      attrs.each do |a|
        @attrs += %Q{ #{a[0]}="#{a[1]}"}
      end
    end

    def append
      str = @attrs
      @attrs = ""
      str
    end

    ESCAPER = HTMLEntities.new

    def escape_html str
      ESCAPER.encode str
    end

    def format_indent
      indent = @buffer.map{ |l| l =~ /[^\s]/ }.reject{ |l| l == 0 }.min
      @buffer.map! { |l| escape_html(l.gsub(/^\s{#{indent}}/, '')) }
      @buffer[0] = "-->" + @buffer[0]
      @buffer[-1] += "<!--"
    end

    def format_buffer
      @buffer.map! do |buf|
        "<p#{append}>#{format_content(buf)}</p>" unless buf.empty?
      end
    end

    INL_SELECTOR = /\{:([^\}]+)\}/
    INL_CODE     = /`(([^\\`]|\\.)*)`/
    INL_IMG_ALT  = /\!\[([^\]]+)\]\(([^\)]+)\)/
    INL_IMG      = /\!\[([^\]]+)\]/
    INL_A        = /\[([^\]]+)\]\(([^\)]+)\)/

    def format_content str
      str.strip!
      loop do
        case str
        when INL_SELECTOR
          selector $1
          str.sub!(INL_SELECTOR, "")
        when INL_CODE
          str.sub!(INL_CODE) {%Q{<code#{append}>#{escape_html($1)}</code>}}
        when INL_IMG_ALT
          str.sub!(INL_IMG_ALT) {%Q{<img src="#{$1}" alt="#{$2}"#{append}>}}
        when INL_IMG
          str.sub!(INL_IMG) {%Q{<img src="#{$1}"#{append}>}}
        when INL_A
          str.sub!(INL_A) {%Q{<a href="#{$1}"#{append}>#{$2}</a>}}
        else
          break
        end
      end
      str
    end
  end
end
