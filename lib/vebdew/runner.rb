require 'parser'

module Vebdew
  module Runner
    module_function

    def generate input, output
      File.open(output, "w") do |f|
        f.write Parser.new(input).to_html
      end
    end
  end
end
