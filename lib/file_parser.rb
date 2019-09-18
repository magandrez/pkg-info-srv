require 'rio'
require 'json'

module FileParser

  def self.get(package)
    package_index = index.select{ |pkg| pkg[0] == package }.flatten
    return [] if package_index.empty?
    read_from = package_index[1] # Package start line in file
    begin
      read_to = arr[arr.index(package_index)+1][1]
    rescue
      # Trying to access arr out of bounds, read until the end.
      read_to = File.foreach('status').inject(0) { |c, line| c+1 }
    end
    parse_text(read_from, read_to)
  end

  def self.find
    all_indices = index.map(&:last)
    all_indices.lazy.each_slice(2).map{ |item| parse_text(item[0], item[1]) }.to_a
  end

  class << self

    private

    def index
      @@index ||= File.open('status') do |file|
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

    def parse_text(from, to)
      text = read_file(from, to)
      text.map!{ |str| str.delete!("\n") }
      result = {}
      result[:name] = parse_name(text)
      result[:description] = parse_description(text)
      result[:depends_on] = parse_dependencies(text)
      result
    end

    def parse_name(text)
      text.select{ |line| /^Package/ =~ line }.first.gsub("Package: ", "")
    end

    def parse_description(text)
      desc_index = 0
      text.select.each_with_index do |item, i|
        desc_index = i if item =~ /^Description:/
      end
      desc = text[desc_index..text.length].select do |item|
        item =~ /^Description/ || item[0] == ' '
      end
      desc.map!{ |item| item.gsub(/^Description: /, '')}
      desc.join
    end

    def parse_dependencies(text)
      dep = []
      dep = text.select{ |line| /^Depends/ =~ line }.first
      return [] if dep.nil?
      arr_dep = dep.gsub("Depends: ", "").gsub(/\(.*?\)/, '').split(",") # Cleanup and split to array
      arr_dep.map! do |elem|
        elem.split("|")[0].strip # Splits by | and takes the first part (i.e. orig dep vs alternative)
      end.uniq # Don't repeat deps
    end

    def read_file(from_line, to_line)
      rio('status').lines[from_line...to_line]
    end
  end
end
