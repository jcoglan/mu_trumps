module PopTrumps
  class Settings
    
    def self.method_missing(key)
      @root ||= new(YAML.load(File.read(ROOT + '/../config/settings.yml')))
      @root.__send__(key)
    end
    
    def initialize(hash)
      @hash = hash
    end
    
    def method_missing(key)
      value = @hash[key.to_s]
      Hash === value ? Settings.new(value) : value
    end
    
  end
end
