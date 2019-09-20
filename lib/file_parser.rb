# frozen_string_literal: true

require 'rio'
require 'json'

# Namespace for functionality that handles file parsing.
#
# This module can parse specific information from Debian
# system's control files.
#
# A specification for control files is available in the Debian Policy Manual:
#
# https://www.debian.org/doc/debian-policy/ch-controlfields.html
#
# For specifics on the information parser, see method documentation.
module FileParser
  # Extracts information for a given package from a control file.
  # The information is read from a static file stored in the
  # service's folder structure.
  #
  # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#list-of-fields
  #   List of fields that describe a package on Debian systems
  #
  # @param [String] package name from which to obtain information.
  # @return [Hash<Symbol, String>] information parsed from control file
  #   for the package name requested.
  def self.get(package)
    package_index = index.select { |pkg| pkg[0] == package }.flatten
    return [] if package_index.empty?

    read_from = package_index[1] # Package start line in file
    begin
      # Accessing arr might fall out of bounds this way
      read_to = arr[arr.index(package_index) + 1][1]
    rescue StandardError
      # Read the file until the last line when arr out of bounds
      read_to = File.foreach('status').inject(0) { |c, _line| c + 1 }
    end
    parse_text(read_from, read_to)
  end

  # Extracts information for all packages from a control
  # file.
  #
  # The source of information is a static file stored in the
  # service's folder structure.
  #
  # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#list-of-fields
  #   List of fields that describe a package on Debian systems
  #
  # @return [Array<Hash>] map containing package info for each of the packages
  #   in control file.
  def self.find
    all_indices = index.map(&:last)
    all_indices.lazy.each_slice(2).map do |item|
      parse_text(item[0], item[1])
    end.to_a
  end

  class << self
    private

    # Generates an index with the lines where each of the packages
    # registered in a control file can be found.
    #
    # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#syntax-of-control-files
    #   Control file's syntax
    # @return [ Array<String,Integer>) ] map containing package name and
    #   start line number of each package in the control file.
    def index
      @index ||= File.open('status') do |file|
        lazy_file = file.each_line.lazy.each_with_index.map do |line, i|
          [line, i]
        end
        lazy_index = lazy_file.select do |line|
          line[0].match(/^Package: /)
        end
        lazy_index.to_a.map! do |array|
          [array[0].gsub!("\n", '').gsub!('Package: ', ''),
           array[1]]
        end
      end
    end

    # Extracts name, description and dependencies of a package
    # from control file.
    # @param [Integer] from line in control file.
    # @param [Integer] to line in control file.
    # @return [Hash] package information.
    #
    #   {
    #     name: String,
    #     description: String,
    #     depends_on: Array<String>
    #    }
    def parse_text(from, to)
      text = read_file(from, to)
      text.map! { |str| str.delete!("\n") }
      result = {}
      result[:name] = parse_name(text)
      result[:description] = parse_description(text)
      result[:depends_on] = parse_dependencies(text)
      result
    end

    # Extracts package name from control file line.
    # @param [Array<String>] text containing package information.
    # @return [String] package name.
    # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#package
    #   Package field in control file
    def parse_name(text)
      text.select { |line| /^Package/ =~ line }.first.gsub('Package: ', '')
    end

    # Extracts package description from control file line.
    # @param [Array<String>] text containing package information.
    # @return [String] package description.
    # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#description
    #   Description field in control files
    def parse_description(text)
      desc_index = 0
      text.select.each_with_index do |item, i|
        desc_index = i if item =~ /^Description:/
      end
      desc = text[desc_index..text.length].select do |item|
        item =~ /^Description/ || item[0] == ' '
      end
      desc.map! { |item| item.gsub(/^Description: /, '') }
      desc.join
    end

    # Extracts dependencies for a given package.
    # @param [Array<String>] text file lines containing package information.
    # @return [Array<String>] list of package dependencies (without versions).
    # @see https://www.debian.org/doc/debian-policy/ch-controlfields.html#package-interrelationship-fields-depends-pre-depends-recommends-suggests-breaks-conflicts-provides-replaces-enhances
    #   Package interrelationship fields
    def parse_dependencies(text)
      dep = text.select { |line| /^Depends/ =~ line }.first
      return [] if dep.nil?

      # Cleanup and split to array
      arr_dep = dep.gsub('Depends: ', '').gsub(/\(.*?\)/, '').split(',')
      arr_dep.map! do |elem|
        # Splits by | and takes the first part (i.e. orig dep vs alternative)
        elem.split('|')[0].strip
      end.uniq # Don't repeat deps
    end

    # Reads a file between lines given as params
    # @param [Integer] from_line
    # @param [Integer] to_line
    # @return [Array<String>] containing package information
    #   line by line.
    def read_file(from_line, to_line)
      rio('status').lines[from_line...to_line]
    end
  end
end
