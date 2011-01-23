dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/pop_trumps'

require 'fileutils'
FileUtils.mkdir_p(dir + '/db')
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => dir + '/db/test.sqlite3')

require dir + '/../config/schema'
