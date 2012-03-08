require 'erubis'

module Vebdew
  class Formatter
    def initialize parser, erb
      @parser = parser
      @erb    = erb

      @header = parser.header.join "\n"
      @body   = parser.body.join "\n"
      @footer = parser.footer.join "\n"
    end

    def to_html
      eruby = Erubis::Eruby.new(@erb)
      eruby.result binding
    end
  end
end
