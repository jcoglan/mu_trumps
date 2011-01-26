dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/mu_trumps'

require 'fileutils'
FileUtils.mkdir_p(dir + '/db')
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => dir + '/db/test.sqlite3')

require dir + '/../config/schema'
require dir + '/factories'

require 'rack/test'
require dir + '/thin_runner'
require 'uri'
require 'net/http'

require dir + '/matchers'

require 'thin'
Thin::Logging.silent = true

require dir + '/web_stubs'

RSpec.configure do |config|
  config.after do
    ObjectSpace.each_object(Class) do |klass|
      klass.delete_all if klass < ActiveRecord::Base
    end
  end
end
