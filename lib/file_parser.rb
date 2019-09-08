require 'rio'
require 'json'

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

  def parse_text(from, to)
    text = read_package(from, to)
    text.map!{ |str| str.delete!("\n") }
    result = {}
    result[:name] = parse_name(text)
    result[:description] = parse_description(text)
    result[:depends_on] = parse_dependencies(text)
    result.to_json
  end

  def parse_name(text)
    text.select{ |line| /^Package/ =~ line }.first.gsub("Package: ", "")
  end

  def parse_description(text)
    description = text.select{|item| item[0] == ' ' || item =~ /^Description/ }.map{|item| item.gsub(/^Description: /, '')}
    description.join("\n")
  end

  def parse_dependencies(text)
    dep = []
    dep = text.select{ |line| /^Depends/ =~ line }.first
    return [] if dep.nil?
    dep.gsub!("Depends: ", "")
    dep.gsub!(/\(.*?\)/, '').# Removes all versioning -- between parentheses
      split(","). # Splits string into array of strings by comma
      map! do |elem|
        elem.split("|")[0].strip # Splits by | and takes the first part (i.e. orig dep vs alternative)
      end.uniq # Don't repeat deps
  end

end
