class WebpayService
  def self.transaction_for(company)
    require "transbank/sdk"

    commerce_code = company.webpay_commerce_code.presence
    api_key = company.webpay_api_key.presence

    if commerce_code && api_key && Rails.env.production?
      ::Transbank::Webpay::WebpayPlus::Transaction.build_for_production(commerce_code, api_key)
    else
      # Default to integration (testing) if credentials are missing or in non-production
      commerce_code = ::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS
      api_key = ::Transbank::Common::IntegrationApiKeys::WEBPAY
      ::Transbank::Webpay::WebpayPlus::Transaction.build_for_integration(commerce_code, api_key)
    end
  end
end
