module RutValidatable
  extend ActiveSupport::Concern

  class_methods do
    def validates_rut(*attributes)
      attributes.each do |attr|
        before_validation -> { clean_rut_attr(attr) }

        validate -> { rut_attr_must_be_valid(attr) }

        define_method("formatted_#{attr}") do
          val = send(attr)
          return "" if val.blank?

          clean = val.to_s.gsub(/[^0-9kK]/, "").upcase
          return clean if clean.length < 2

          body = clean[0...-1]
          dv = clean[-1]

          formatted_body = body.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
          "#{formatted_body}-#{dv}"
        end
      end
    end
  end

  private

  def clean_rut_attr(attr)
    val = send(attr)
    return if val.blank?
    send("#{attr}=", val.to_s.gsub(/[^0-9kK]/, "").upcase)
  end

  def rut_attr_must_be_valid(attr)
    val = send(attr)
    return if val.blank?

    clean_rut_val = val.to_s.gsub(/[^0-9kK]/, "").upcase
    return if clean_rut_val.length < 2

    body = clean_rut_val[0...-1]
    dv = clean_rut_val[-1]

    sum = 0
    multiplier = 2
    body.reverse.each_char do |c|
      sum += c.to_i * multiplier
      multiplier = multiplier == 7 ? 2 : multiplier + 1
    end

    expected_dv = 11 - (sum % 11)
    expected_dv = case expected_dv
    when 11 then "0"
    when 10 then "K"
    else expected_dv.to_s
    end

    errors.add(attr, :invalid) if dv != expected_dv
  end
end
