=begin

# XXX: This code is unfinished

module Memorandom
module Plugins
class RSA < PluginTemplate

  require 'openssl'

  @description = "This plugin looks for RSA keys by finding Bignum-encoded p-values"
  @confidence  = 0.90

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)

    key_lengths = [1024, 2048]

    key_lengths.each do |bits|
      p_size = bits / 16
      n_size = bits / 8

      found = []
      0.upto(buffer.length - (p_size + n_size)) do |p_offset|

        # Look for a prime of the right size (p or q)
        found_p = OpenSSL::BN.new( buffer[p_offset, p_size].unpack("H*").first.to_i(16).to_s )
        next unless found_p.prime?
        next unless found_p > 0x1000000000000000000000

        # Look for a modulus that matches the found p/q value
        0.upto(buffer.length - (p_size + n_size) ) do |n_offset|

          next if (n_offset < p_offset and (n_offset + n_size) > p_offset)
          next if (p_offset < n_offset and (p_offset + p_size) > n_offset)

          found_n = OpenSSL::BN.new(buffer[n_offset, n_size].unpack("H*").first.to_i(16).to_s )

          next if found_n == 0
          next if found_n == found_p
          next unless found_n > 0x1000000000000000000000
          next unless (found_n % found_p == 0)

          found << [found_p, found_n, p_offset]
        end
      end

      found = found.uniq 

      next unless found.length > 0

      mods = {}

      # Track the last unique p/q value for a potential modulus
      found.each do |info|
        mods[ info[1] ] ||= {}
        mods[ info[1] ][ info[0] ] = info[2]
      end
      p mods

      next 
      
      mods.keys.each do |n|
        uniq_pees = mods[n].keys.select do |k|
          mods[n].keys.reject {|x| x == k}.select{|x| n == (x * k) }
        end
      end


    end
  end

end
end
end

=end
