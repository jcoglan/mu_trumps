dir = File.expand_path(File.dirname(__FILE__))
require dir + '/../lib/pop_trumps'

require 'fileutils'
FileUtils.mkdir_p(dir + '/db')
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => dir + '/db/test.sqlite3')

require dir + '/../config/schema'
require dir + '/factories'

require 'fakeweb'
FakeWeb.allow_net_connect = false

FakeWeb.register_uri(:get, 'http://ws.audioscrobbler.com/2.0/?user=jcoglan&method=user.gettopartists&format=json&api_key=fdb6a3b0db7da333c1eb1a7167160397',
                     :body => File.read(dir + '/fixtures/top_artists.json'))

RSpec.configure do |config|
  config.after do
    ObjectSpace.each_object(Class) do |klass|
      klass.delete_all if klass < ActiveRecord::Base
    end
  end
end
