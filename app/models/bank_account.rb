class BankAccount < ApplicationRecord
  belongs_to :company

  enum :bank_name, {
    state_bank: "Banco Estado",
    bank_of_chile: "Banco de Chile",
    santander: "Banco Santander",
    bci: "Banco BCI",
    itau: "Banco Itaú",
    scotiabank: "Scotiabank",
    falabella: "Banco Falabella",
    ripley: "Banco Ripley",
    security: "Banco Security",
    bice: "Banco BICE",
    international_bank: "Banco Internacional",
    consorcio: "Banco Consorcio",
    coopeuch: "Coopeuch",
    tenpo: "Tenpo",
    mach: "MACH",
    mercado_pago: "Mercado Pago",
    copec_pay: "Copec Pay",
    chek: "Chek",
    tapp: "Tapp",
    dale: "Dale Coopeuch",
    global66: "Global66",
    prex: "Prex",
    los_heroes: "Los Héroes Prepago",
    superdigital: "Superdigital",
    btg_pactual: "BTG Pactual",
    hsbc: "HSBC",
    tanner: "Tanner",
    jp_morgan: "JP Morgan",
    bank_of_china: "Bank of China",
    china_construction_bank: "China Construction Bank"
  }, default: :state_bank

  enum :account_type, {
    checking: "Cuenta Corriente",
    sight: "Cuenta Vista / RUT",
    savings: "Cuenta de Ahorro",
    prepaid: "Cuenta de Prepago"
  }, default: :checking

  validates :bank_name, :account_type, :account_number, :holder_name,
            :holder_rut, :holder_email, presence: true

  before_validation :clean_holder_rut
  validate :holder_rut_must_be_valid

  def localized_bank_name
    I18n.t("enums.bank_account.bank_name.#{bank_name}", default: bank_name.to_s.humanize)
  end

  def localized_account_type
    I18n.t("enums.bank_account.account_type.#{account_type}", default: account_type.to_s.humanize)
  end

  private

  def clean_holder_rut
    return if holder_rut.blank?
    self.holder_rut = holder_rut.to_s.gsub(/[^0-9kK]/, "").upcase
  end

  def holder_rut_must_be_valid
    return if holder_rut.blank?

    clean_rut_val = holder_rut.gsub(/[^0-9kK]/, "").upcase
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

    errors.add(:holder_rut, :invalid) if dv != expected_dv
  end
end
