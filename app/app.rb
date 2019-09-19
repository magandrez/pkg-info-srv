require 'sinatra/base'
require 'json'

# Main class where routes for service are registered.
class App < Sinatra::Base
  set :show_exceptions, false
  set :public_folder, './doc'

  before do
    content_type :json
  end

  get '/' do
    'Moi!'
  end

  get '/api/packages/:package_name' do
    res = FileParser.get(params[:package_name])
    halt 404, 'Package not found' if res.empty?
    res.to_json
  end

  get '/api/packages/' do
    result = FileParser.find
    result.to_json
  end

  get '/doc' do
    content_type 'text/html'
    send_file File.join(settings.public_folder, 'index.html')
  end
end
