class AppController < Sinatra::Base

  $fp = FileParser.new('status')
  $fp.load_file_map

  get '/' do
    'Moi!'
  end

  get '/api/packages/:package_name' do
    $fp.load_file_map
    arr = $fp.file_map
    package_index = arr.select{ |package| package[0] == params[:package_name] }.flatten
    unless package_index.empty?
      content_type :json
      read_from = package_index[1] # Package start line in file
      begin
        read_to = arr[arr.index(package_index)+1][1]
      rescue
        # Trying to access arr out of bounds, read until the end.
        read_to = File.foreach('status').inject(0) { |c, line| c+1 }
      end
      result = $fp.parse_text(read_from, read_to)
      result.to_json
    else
      halt 404, 'Package not found!'
    end
  end
end
