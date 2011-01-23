module PopTrumps
  class User < ActiveRecord::Base
    has_and_belongs_to_many :artists, :uniq => true
  end
end
