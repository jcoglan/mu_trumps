RSpec::Matchers.define :take do |duration|
  match do |proc|
    begin
      start = Time.now
      proc.call
      diff = Time.now - start
      
      case duration
      when Numeric then diff >= duration
      when Range then diff >= duration.begin and diff < duration.end
      end
    rescue => e
      false
    end
  end
end
