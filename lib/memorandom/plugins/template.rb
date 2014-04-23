module Memorandom
class PluginTemplate

  @@description = "This is an unconfigured plugin using the base template"
  @@confidence  = 0.80

  attr_accessor :scanner, :hits

  def initialize(scanner)
    self.scanner = scanner
    self.hits = {}
  end

  def report_hit(info = {})
    unless info[:offset] and info[:type]
      raise RuntimeError, "No offset or type supplied in the hit: #{info.inspect}"
    end

    scanner.report_hit(info.merge({:plugin => self }))

    offset = info.delete(:offset)
    self.hits[offset] = info
  end

  def reset
    self.hits = {}
  end

  def self.description
    @@description
  end

  def self.confidence
    @@confidence
  end

  def description
    self.class.description
  end

  def confidence
    self.class.confidence
  end

end
end
