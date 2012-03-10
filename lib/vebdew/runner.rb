require 'fileutils'

module Vebdew
  module Runner
    module_function

    def create
      dir = File.join File.dirname(__FILE__), "../template/*"
      Dir[File.expand_path dir].each do |file|
        FileUtils.cp_r file, Dir.pwd
      end
      puts "Vebdew project generated!"
    end

    def generate
      vew = File.join Dir.pwd, "vew"
      temp = File.join vew, "template.erb"

      if !File.exist?(vew) or !File.directory?(vew)
        puts "Is this a Vebdew project? 'vew' directory does not exist!"
      elsif !File.exist?(temp)
        puts "The template file 'vew/template.erb' does not exist!"
      else
        Dir[File.join vew, "*.vew"].each do |file|
          html = File.basename(file, ".vew") + ".html"
          compile file, temp, File.join(Dir.pwd, html)
          puts "#{html} compiled!"
        end
      end
    end

    def compile vew, erb, html
      if !File.exist?(vew)
        puts "Vew file doesn't exist!"
      elsif !File.exist?(erb)
        puts "Erb template doesn't exist!"
      else
        parser = Parser.new(IO.readlines(vew))
        result = Formatter.new(parser, File.read(erb)).to_html
        File.open(html, "w") { |f| f.write result }
      end
    end
  end
end
