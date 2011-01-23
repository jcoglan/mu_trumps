dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/pop_trumps'

require 'fileutils'
FileUtils.mkdir_p(dir + '/db')
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => dir + '/db/test.sqlite3')

require dir + '/../config/schema'
require dir + '/factories'

RSpec.configure do |config|
  config.after do
    ObjectSpace.each_object(Class) do |klass|
      klass.delete_all if klass < ActiveRecord::Base
    end
  end
end
