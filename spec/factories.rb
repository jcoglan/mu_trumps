require 'factory_girl'

Factory.define :artist, :class => MuTrumps::Artist do |a|
  a.name 'Imogen Heap'
  a.image_url 'http://userserve-ak.last.fm/serve/34/59404.jpg'
end

Factory.define :game, :class => MuTrumps::Game do |g|
end

Factory.define :user, :class => MuTrumps::User do |u|
  u.lastfm_username 'alice'
end
