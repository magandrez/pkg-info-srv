# frozen_string_literal: true

require 'spec_helper'
require './lib/file_parser'
require 'pry'

RSpec.describe FileParser do
  let(:one_pkg_file) { File.expand_path('./spec/fixtures/one_package_file') }
  let(:file_length) do
    File.foreach(one_pkg_file).inject(0) { |c, _line| c + 1 }
  end
  let(:fixture) { File.open(one_pkg_file) }
  let(:text) do
    arr = File.readlines(one_pkg_file).to_a
    arr.map! { |str| str.delete!("\n") }
    arr
  end

  before :each do
    allow(File).to receive(:readlines).and_return(fixture)
  end

  describe '.last_line' do
    let(:buffer) { StringIO.new("1\n2\n3") }

    before :each do
      allow(File).to receive(:foreach).and_return(buffer)
    end

    it 'should be a an integer' do
      expect(described_class.send(:line_num).class).to eq Integer
    end

    it 'should be positive' do
      expect(described_class.send(:line_num)).to be > 0
    end
  end

  describe '.read_file' do
    it 'should be an Array' do
      expect(described_class.send(:read_file, 0, 1).class).to eq Array
    end

    it 'should be contain 3 items when read three lines' do
      expect(described_class.send(:read_file, 0, 3).size).to eq 3
    end

    it 'should contain strings' do
      expect(described_class.send(:read_file, 0, 1).first.class).to eq String
    end
  end

  context 'Info parsed from text file' do
    describe '.parse_dependencies' do
      it 'should parse dependencies into an Array' do
        expect(described_class.send(:parse_dependencies, text).class)
          .to eq Array
      end

      it 'should parse two dependencies' do
        expect(described_class.send(:parse_dependencies, text).count).to eq 2
      end

      it 'should list dependencies without version numbers' do
        expect(described_class.send(:parse_dependencies, text).first.class)
          .to eq String
      end
    end

    describe '.parse_description' do
      it 'should parse description into a String' do
        expect(described_class.send(:parse_description, text).class)
          .to eq String
      end

      it 'should parse all the description lines' do
        expect(described_class.send(:parse_description, text))
          .to match(/I don't know what to say./)
      end
    end

    describe '.parse_name' do
      it 'should parse package name into a String' do
        expect(described_class.send(:parse_name, text).class).to eq String
      end

      it "should not contain the string 'Package'" do
        expect(described_class.send(:parse_name, text)).not_to match(/Package/)
      end
    end

    describe '.parse_text' do
      it 'should parse a file with a single package into a Hash' do
        expect(described_class.send(:parse_text, 0, file_length).class)
          .to eq Hash
      end

      it 'should parse a file into a Hash with specific keys' do
        expect(described_class.send(:parse_text, 0, file_length))
          .to include(:name, :description, :depends_on)
      end
    end
  end
end
