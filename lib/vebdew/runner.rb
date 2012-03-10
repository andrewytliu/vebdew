module Vebdew
  module Runner
    module_function

    def create
    end

    def generate
      vew = File.join Dir.pwd, "vew"
      temp = File.join vew, "template.erb"

      if !File.exist? vew
        puts "Is this a Vebdew project? 'vew' directory does not exist!"
      elsif !File.exist? temp
        puts "The template file 'vew/template.erb' does not exist!"
      else
        Dir[File.join vew, "*.vew"].each do |file|
          html = File.basename(file, ".vew") + ".html"
          compile file, temp, File.join(Dir.pwd, html)
        end
      end
    end

    def compile vew, erb, html
      parser = Parser.new(IO.readlines(vew))
      result = Formatter.new(parser, File.read(erb)).to_html
      File.open(html, "w") { |f| f.write result }
    end
  end
end
