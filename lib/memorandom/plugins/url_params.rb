module Memorandom
module Plugins
class URLParams < PluginTemplate

  @@description = "This plugin looks for interesting URL parameters and POST data"
  @@confidence  = 0.50

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)
    buffer.scan(
      /[%a-z0-9_\-=\&]*(?:sid|session|sess|user|usr|login|pass|secret|token)[%a-z0-9_\-=\&]*=[%a-z0-9_\-=&]+/mi
    ).each do |m|
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      report_hit(:type => 'URLParams', :data => m, :offset => source_offset + last_offset)
      last_offset += m.length
    end
  end

end
end
end