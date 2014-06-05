module Memorandom
module Plugins
class Hashes < PluginTemplate

  @description = "This plugin looks for common hash formats"
  @confidence  = 0.10

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)

    # Unix password hash formats
    buffer.scan(
      /[a-z0-9_]+:\$\d+\$[$a-z0-9\.\/]+:\d+:\d+:\d+[a-z0-9 :]*/mi
    ).each do |m|
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      report_hit(:type => 'UnixHash', :data => m, :offset => source_offset + last_offset)
      last_offset += m.length
    end

    # Hexadecimal password hashes
    buffer.scan(
      /[a-f0-9]{16,128}/mi
    ).each do |m|
      next unless m.length % 2 == 0
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      report_hit(:type => 'CommonHash', :data => m, :offset => source_offset + last_offset)
      last_offset += m.length
    end

  end

end
end
end
