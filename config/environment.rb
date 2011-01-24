dir = File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'active_record'
require 'acts_as_list'
require 'fileutils'
FileUtils.mkdir_p(dir + '/../db')

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => dir + '/../db/mu_trumps.sqlite3')
