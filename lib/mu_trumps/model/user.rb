module MuTrumps
  class User < ActiveRecord::Base
    has_and_belongs_to_many :artists, :uniq => true
    
    def self.[](username)
      find_or_create_by_lastfm_username(username)
    end
  end
end
