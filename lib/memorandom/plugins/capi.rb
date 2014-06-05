module Memorandom
module Plugins
class CAPI < PluginTemplate

  require 'openssl'

  @description = "This plugin looks for Microsoft CryptoAPI encryption keys in memory (PRIVATEBLOB)"
  @confidence  = 0.90

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)

    buffer.scan(
      /[\x06\x07]\x02.{6}(?:RSA1|RSA2|DSS1|DSS2).{20}/
    ).each do |m|
      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(m)
      next unless last_offset 

      # Attempt to parse the key at the specified offset
      key_candidate = buffer[last_offset, 20000]
      key_type = ""
      key      = nil

      bits = key_candidate.unpack("CCA6A4V")
      key_type << ( bits[3] + "-" + bits[4].to_s + "-" )
      key_type << ( (bits[0] == 0x07) ? "Private" : "Public" )

      key_length = 0
      nbyte  = (bits[4] +  7) >> 3
      hnbyte = (bits[4] + 15) >> 4 

      # DSA
      if bits[3].index('DSS')
        if bits[0] == 0x06
          # Expected length: 20 for q + 3 components bitlen each + 24 for seed structure.
          key_length = 44 + (3 * nbyte)
        else
          # Expected length: 20 for q, priv, 2 bitlen components + 24 for seed structure.
          key_length = 64 + (2 * nbyte)
        end
      # RSA
      else
        if bits[0] == 0x06
          # Expected length: 4 for 'e' + 'n'
          key_length = 4 + nbyte
        else
          # Expected length: 4 for 'e' and 7 other components. 2 components are bitlen size, 5 are bitlen/2
          key_length = 4 + (2 * nbyte) + (5 * hnbyte)
        end
      end

      key = buffer[last_offset, key_length + 16]
      next unless key.length == (key_length+16)

      report_hit(:type => "CAPI-#{key_type}", :data => key, :offset => source_offset + last_offset)
    end
  end

end
end
end
