dir = File.expand_path(File.dirname(__FILE__))

require 'fakeweb'
FakeWeb.allow_net_connect = %r[^https?://localhost]

FakeWeb.register_uri(:get, 'http://ws.audioscrobbler.com/2.0/?user=jcoglan&method=user.gettopartists&format=json&api_key=fdb6a3b0db7da333c1eb1a7167160397',
                     :body => File.read(dir + '/fixtures/top_artists.json'))
    
FakeWeb.register_uri(:get, 'http://developer.echonest.com/api/v4/artist/search?api_key=WDYWSAVVILHXV5RHT&format=json&name=Imogen+Heap',
                     :body => File.read(dir + '/fixtures/echonest_search.json'))

FakeWeb.register_uri(:get, 'http://developer.echonest.com/api/v4/artist/hotttnesss?api_key=WDYWSAVVILHXV5RHT&id=AR7W7171187B9A8842&format=json',
                     :body => File.read(dir + '/fixtures/hotttnesss.json'))

FakeWeb.register_uri(:get, 'http://developer.echonest.com/api/v4/artist/familiarity?api_key=WDYWSAVVILHXV5RHT&id=AR7W7171187B9A8842&format=json',
                     :body => File.read(dir + '/fixtures/familiarity.json'))

FakeWeb.register_uri(:get, 'http://api.7digital.com/1.2/artist/search?q=Imogen+Heap&oauth_consumer_key=7de69j69ya&country=GB',
                     :body => File.read(dir + '/fixtures/7digital.xml'))
