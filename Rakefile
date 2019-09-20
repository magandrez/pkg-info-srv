# Add current path and lib to the load path
$LOAD_PATH << File.expand_path('../', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: ['default:all']
