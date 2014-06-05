module Memorandom
module Plugins
class DER < PluginTemplate

  require 'openssl'

  @description = "This plugin looks for DER-encoded encryption keys (RSA/DSA/EC)"
  @confidence  = 0.90

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)

    buffer.scan(
      # Look for a DER record start (0x30), a length value, and a version marker. 
      # This identifies RSA, DSA, and EC keys
      /\x30.{1,5}\x02\x01(?:\x00\x02|\x01\x04)/m
    ).each do |m|
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      next unless last_offset 

      # Attempt to parse the key at the specified offset
      key_candidate = buffer[last_offset, 20000]
      key_type = nil
      key      = nil

      [:RSA, :DSA, :EC ].each do |ktype|
        next unless OpenSSL::PKey.const_defined?(ktype)
        key_type = ktype
        key = OpenSSL::PKey.const_get(ktype).new(key_candidate) rescue nil
        break if key
      end

      # Ignore this if OpenSSL could not parse out a valid key
      next unless key

      report_hit(:type => "#{key_type}", :data => key.to_pem, :offset => source_offset + last_offset)
    end
  end

end
end
end
