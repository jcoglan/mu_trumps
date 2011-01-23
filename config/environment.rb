dir = File.expand_path(File.dirname(__FILE__))

require 'active_record'
require 'fileutils'
FileUtils.mkdir_p(dir + '/../db')

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => dir + '/../db/pop_trumps.sqlite3')
