require 'factory_girl'

Factory.define :artist, :class => PopTrumps::Artist do |a|
  a.name 'Imogen Heap'
end

Factory.define :game, :class => PopTrumps::Game do |g|
end

Factory.define :user, :class => PopTrumps::User do |u|
  u.lastfm_username 'alice'
end
