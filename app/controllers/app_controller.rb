class AppController < Sinatra::Base

  $fp = FileParser.new('status')
  $fp.load_file_map

  get '/' do
    'Moi!'
  end

  get '/api/packages/:package_name' do
    $fp.load_file_map
    arr = $fp.file_map
    packages = arr.map{|a| a[0]}
    if packages.include? params[:package_name]
      'Yay!'
    else
      halt 404, 'Package not found!'
    end
  end
end
