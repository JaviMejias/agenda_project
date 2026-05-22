require 'transbank/sdk'

tx = ::Transbank::Webpay::WebpayPlus::Transaction.build_for_integration(
  ::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS,
  ::Transbank::Common::IntegrationApiKeys::WEBPAY
)

resp = tx.create("ORD-#{Time.now.to_i}", "SES-#{Time.now.to_i}", 1000, "http://localhost:3000/return")
puts resp.class
puts resp.inspect
