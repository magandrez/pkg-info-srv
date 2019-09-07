require 'rio'

class FileParser

  attr_reader :file_map

  @file_map = []

  def initialize(file)
    @file = file
  end

  def load_file_map
    @file_map = File.open('status'){ |f| f.each_line.lazy.each_with_index.map { |line, i| [line, i] }.select{|line| line[0].match(/Package: /)}.to_h.transform_keys!{|k| k.delete("Packages: ").delete("\n")}.to_a}
  end

  def read_package(from_line, to_line)
    rio(@file).lines(from_line, to_line)
  end

end
