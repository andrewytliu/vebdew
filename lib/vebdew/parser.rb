require 'kramdown'

module Vebdew
  class Parser
    def initialize file
      @lines = IO.readlines(file)
      @output = []
      @buffer = []
    end

    def to_html
      @output.join "\n"
    end

  protected
    def parse
      flag = Hash.new { |h, k| h[k] = false }
      contain = @output

      for raw_line in @lines
        line = raw_line.lstrip

        case line
        when /^:(\w+) (.*)$/
          case $1
          when "description"
            @output << %q{<meta name="description" content="#{$2}">}
          when "author"
            @output << %q{<meta name="author" content="#{$2}">}
          when "email"
            @output << %q{<meta name="email" content="#{$2}">}
          when "stylesheet_link_tag"
            $2.split(',').each do |href|
              @output << %q{<link rel="stylesheet" href="#{href}">}
            end
          when "javascript_include_tag"
            $2.split(',').each do |href|
              @output << %q{<script type="text/javascript" src="#{href}"></script>}
            end
          else
            # TODO: something wrong!
          end
        when /^\!SLIDE/
          close_buffer
          @output << "</section>" if flag[:slide]
          @output << "<section>"
          flag[:slide] = true
        when /^\!ENDSLIDE/
          close_buffer
          @output << "</section>"
          flag[:slide] = false
        when /^\!STACK/
          close_buffer
          if flag[:slide]
            @output << "</section>"
            flag[:slide] = false
          end
          @output << "</section>" if flag[:stack]
          @output << "<section>"
          flag[:stack] = true
        when /^\!ENDSTACK/
          close_buffer
          if flag[:slide]
            @output << "</section>"
            flag[:slide] = false
          end
          @output << "</section>"
          flag[:stack] = false
        else
          @buffer << line
        end
      end

      def close_buffer
        @output << "<p>"
        @output += @buffer
        @output << "</p>"
        @output.clear
      end
    end
  end
end
