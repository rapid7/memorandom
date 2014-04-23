module Memorandom
module Plugins
class PEM < PluginTemplate

  @@description = "This plugin looks for PEM-encoded data (keys, certificates, crls, etc)"
  @@confidence  = 0.90

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)
    buffer.scan(
      /-----BEGIN\s*[^\-]+-----+\r?\n[^\-]*-----END\s*[^\-]+-----\r?\n?/m
    ).each do |m|
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      report_hit(:plugin => self, :type => 'PEM', :data => m, :offset => source_offset + last_offset)
      last_offset += m.length
    end
  end

end
end
end