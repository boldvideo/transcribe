# app/services/transcription.rb

require 'net/http'
require 'uri'
require 'json'

module Transcription
  DEEPGRAM_API_URL = 'https://api.deepgram.com/v1/listen?model=nova-2'

  def self.transcribe_audio(url)
    callback_url = Rails.application.routes.url_helpers.transcription_callbacks_url(
      host: ENV['HOSTNAME'] || 'localhost:3000'
    )

    uri = URI("#{DEEPGRAM_API_URL}&callback=#{CGI.escape(callback_url)}&utterances=true&smart_format=true")
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Token #{Rails.application.credentials.deepgram[:api_key]}"
    request['Content-Type'] = 'application/json'
    request.body = { url: url }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end
end

