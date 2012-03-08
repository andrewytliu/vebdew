module Vebdew
  module Runner
    module_function

    def generate vew, erb, html
      parser = Parser.new(IO.readlines(vew))
      result = Formatter.new(parser, File.read(erb)).to_html
      File.open(html, "w") { |f| f.write result }
    end
  end
end
