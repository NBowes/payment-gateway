require 'sinatra'
require 'httparty'
require 'openssl'
require 'pry'

class BkPayments < Sinatra::Base
  post '/checkout' do
    fields = params.select{|k,v| k.start_with? 'x_'}
    fields.delete('x_signature')
    message = fields.sort.join
    key = 'nbowes'

    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, message)

    payload = {
      x_account_id: params['x_account_id'],
      x_reference: params['x_reference'],
      x_currency: params['x_currency'],
      x_test: params['x_test'],
      x_amount: params['x_amount'],
      x_gateway_reference: "BK-" + "#{rand(10**15)}",
      x_timestamp: Time.now.utc,
      x_result: 'completed',
    }
    response_message = payload.sort.join

    payload['x_signature'] = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),key, response_message)
    callback_url = params['x_url_callback']

    response = HTTParty.post(callback_url, body: payload)
    redirect params['x_url_complete']
  end
end

BkPayments.run!
