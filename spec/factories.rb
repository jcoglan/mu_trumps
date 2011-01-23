require 'factory_girl'

Factory.define :artist, :class => PopTrumps::Artist do |a|
  a.name 'Imogen Heap'
  a.image_url 'http://userserve-ak.last.fm/serve/34/59404.jpg'
end

Factory.define :game, :class => PopTrumps::Game do |g|
end

Factory.define :user, :class => PopTrumps::User do |u|
  u.lastfm_username 'alice'
end
