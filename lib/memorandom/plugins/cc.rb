module Memorandom
module Plugins
class CC < PluginTemplate

  # Use the credit_card_validator gem for luhn checks and card verification
  require 'credit_card_validator'

  @description = "This plugin looks for credit card numbers"
  @confidence  = 0.10

  # Scan takes a buffer and an offset of where this buffer starts in the source
  def scan(buffer, source_offset)

    buffer.scan(
      # Look for credit card numbers in various formats
      /(?:^|\D)([\d \-]{12,32})(?:$|\D)/
    ).each do |m|
      matched = m.first

      # This may hit an earlier identical match, but thats ok
      last_offset = buffer.index(matched)
      next unless last_offset

      # Clean out any non-digits and validate the card
      cleaned = matched.gsub(/[^\d]+/, '')
      next unless CreditCardValidator::Validator.valid?(cleaned)
      cc_type = CreditCardValidator::Validator.card_type(cleaned)
      cc_type = cc_type.split('_').map{|x| x.capitalize }.join

      report_hit(:type => "CreditCard(#{cc_type})", :data => cleaned, :offset => source_offset + last_offset)
    end
  end

end
end
end
