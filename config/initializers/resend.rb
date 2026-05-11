# frozen_string_literal: true

if Rails.env.production?
  Resend.api_key = ENV.fetch("RESEND_API_KEY")
end
