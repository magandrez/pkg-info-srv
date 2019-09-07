require 'rio'

class FileParser

  attr_reader :file_map

  @file_map = []

  def initialize(file)
    @file = file
  end

  def load_file_map
    @file_map = File.open('status') do |file|
      lazy_file = file.each_line.lazy.each_with_index.map do |line, i|
        [line, i]
      end
      lazy_index = lazy_file.select do |line|
        line[0].match(/^Package: /)
      end
      lazy_index.to_a.map! do |array|
        [
          array[0].gsub!("\n", "").gsub!("Package: ",""),
          array[1]
        ]
      end
    end
  end

  def read_package(from_line, to_line)
    rio(@file).lines[from_line...to_line]
  end

end
