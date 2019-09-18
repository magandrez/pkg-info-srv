require 'sinatra/base'
require 'json'

class App < Sinatra::Base
  set :show_exceptions, false

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
end
