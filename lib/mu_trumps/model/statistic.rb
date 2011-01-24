module MuTrumps
  class Statistic < ActiveRecord::Base
    belongs_to :artist
    validates_presence_of :artist, :name, :value
    validates_uniqueness_of :name, :scope => :artist_id
  end
end
