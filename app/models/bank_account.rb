class BankAccount < ApplicationRecord
  include RutValidatable
  validates_rut :holder_rut

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

  def localized_bank_name
    I18n.t("enums.bank_account.bank_name.#{bank_name}", default: bank_name.to_s.humanize)
  end

  def localized_account_type
    I18n.t("enums.bank_account.account_type.#{account_type}", default: account_type.to_s.humanize)
  end
end
