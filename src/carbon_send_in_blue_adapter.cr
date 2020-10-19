require "http"
require "json"

class Carbon::SendInBlueAdapter < Carbon::Adapter
  private getter api_key : String

  def initialize(@api_key)
  end

  def deliver_now(email : Carbon::Email)
    Carbon::SendInBlueAdapter::Email.new(email, api_key).deliver
  end

  class Email
    BASE_URI       = "api.sendinblue.com"
    MAIL_SEND_PATH = "/v3/smtp/email"
    private getter email, api_key

    def initialize(@email : Carbon::Email, @api_key : String)
    end

    def deliver
      client.post(MAIL_SEND_PATH, body: params.to_json).tap do |response|
        unless response.success?
          raise JSON.parse(response.body).inspect
        end
      end
    end

    def params
      {
        to:               to_send_in_blue_address(email.to),
        subject:          email.subject,
        sender:           from,
        htmlContent:      email.html_body,
        textContent:      email.text_body
      }
    end

    private def to_send_in_blue_address(addresses : Array(Carbon::Address))
      addresses.map do |carbon_address|
        {
          name:  carbon_address.name,
          email: carbon_address.address,
        }
      end
    end

    private def reply_to_params
      if reply_to_address
        {email: reply_to_address}
      end
    end

    private def reply_to_address : String?
      reply_to_header.values.first?
    end

    private def reply_to_header
      email.headers.select do |key, _value|
        key.downcase == "reply-to"
      end
    end

    private def headers : Hash(String, String)
      email.headers.reject do |key, _value|
        key.downcase == "reply-to"
      end
    end

    private def from
      {
        email: email.from.address,
        name:  email.from.name,
      }.to_h.reject do |_key, value|
        value.nil?
      end
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(BASE_URI, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          request.headers["api-key"] = "#{api_key}"
          request.headers["content-type"] = "application/json"
          request.headers["accept"] = "application/json"
        end
      end
    end
  end
end
