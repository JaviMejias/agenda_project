module RutValidatable
  extend ActiveSupport::Concern

  included do
    before_validation :clean_rut
    validate :rut_must_be_valid
  end

  private

  def clean_rut
    return if rut.blank?
    self.rut = rut.to_s.gsub(/[^0-9kK]/, "").upcase
  end

  def rut_must_be_valid
    return if rut.blank?

    clean_rut_val = rut.gsub(/[^0-9kK]/, "").upcase
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

    errors.add(:rut, :invalid) if dv != expected_dv
  end
end
