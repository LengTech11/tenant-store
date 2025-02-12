class PaymentsController < ApplicationController
  before_action :generate_transaction_hash, only: [ :checkout ]
  before_action :generate_check_transaction_hash, only: [ :success ]


  def checkout
    @create_transaction_params = {
      req_time: Time.zone.now.strftime("%Y%m%d%H%M%S"),
      merchant_id: "hangmeasmobile",
      tran_id: "lengTech11",
      amount: "999",
      payment_option: "abapay"
    }

    hash_data = @create_transaction_params.slice(
      :req_time,
      :merchant_id,
      :tran_id,
      :amount,
      :payment_option
    ).values.join(" ")

    public_key = "ecb49bf5-9537-424d-8745-891e47e0813a"

    hash_data = @create_transaction_params.slice(:req_time, :merchant_id, :tran_id, :amount, :payment_option).values.join("")
    hash = Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha512"), public_key, hash_data))

    @create_transaction_params[:hash] = hash
  end

  def success
    check_transaction_params = {
      language: "km",
      request_time: Time.current.strftime("%Y%m%d%H%M%S"),
      merchant_id: merchant_id,
      tran_id: params[:tran_id],
      hash: @transaction_hash
    }

    response = Faraday.post(
      "https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/check-transaction",
      check_transaction_params.to_json,
      { "Content-Type" => "application/json" }
    )

    @response_data = JSON.parse(response.body)
  end

  private

  def merchant_id
    ENV["MERCHANT_ID"] || "LengTechShop"
  end

  def public_key
    ENV["PUBLIC_KEY"] || "ecb49bf5-9537-424d-8745-891e47e0813a"
  end

  def tran_id
    params[:tran_id] || SecureRandom.uuid
  end

  def encoded_items
    Base64.strict_encode64([
      { name: "Iphone 11", quantity: 1, price: 1 },
      { name: "Iphone 12", quantity: 1, price: 9 }
    ].to_json)
  end

  def generate_transaction_hash
    hash_data = [
      Time.current.strftime("%Y%m%d%H%M%S"),
      merchant_id,
      tran_id,
      10,
      encoded_items,
      "Leng",
      "Tech11",
      "LengTech11@gmail.com",
      "+85561706202",
      "purchase",
      "abapay_khqr",
      success_url(tran_id)
    ].join(" ")

    @transaction_hash = generate_hash(hash_data)
  end

  def generate_check_transaction_hash
    hash_data = [
      Time.current.strftime("%Y%m%d%H%M%S"),
      merchant_id,
      params[:tran_id]
    ].join("")

    @transaction_hash = generate_hash(hash_data)
  end

  def generate_hash(data)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha512"), public_key, data)
  end

  def success_url(tran_id)
    "http://localhost:3000/success?tran_id=#{tran_id}"
  end
end
