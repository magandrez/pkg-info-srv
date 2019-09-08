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
      # TODO: make the below call safe for EOF errors
      info_hash = $fp.parse_text(package_index[1], # Package start line in file
                                 arr[arr.index(package_index)+1][1]) # Package end line (the beginning of the next in the map)
    else
      halt 404, 'Package not found!'
    end
  end
end
