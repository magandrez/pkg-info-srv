class AppController < Sinatra::Base

  $fp = FileParser.new('status')
  $fp.load_file_map

  get '/' do
    'Moi!'
  end

  get '/api/packages/:package_name' do
    $fp.load_file_map
    arr = $fp.file_map
    package_index = arr.select{ |package| package[0].include? params[:package_name] }.flatten
    unless package_index.empty?
      text = $fp.read_package(package_index[1], # Package start line in file
                              arr[arr.index(package_index)+1][1]) # Package end line (the beginning of the next in the map)
      text
    else
      halt 404, 'Package not found!'
    end
  end
end
