class TextToSpeechJob < ApplicationJob
  queue_as :default

  def perform(prompt)
    Rails.logger.info("Starting TextToSpeechJob for prompt: #{prompt}")

    response = Faraday.post('https://api.elevenlabs.io/v1/text-to-speech/tnSpp4vdxKPjI9w0GnoV') do |req|
      req.headers['accept'] = 'audio/mpeg'
      req.headers['xi-api-key'] = Rails.application.credentials.xi_api_key
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        text: prompt,
        model_id: 'eleven_monolingual_v1',
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.5
        }
      }.to_json
    end

    if response.success?
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(response.body),
        filename: 'audio.mp3',
        content_type: 'audio/mpeg'
      )

      audio = Audio.create!(prompt: prompt, file: blob)
      Rails.logger.info("Successfully created Audio ##{audio.id} for prompt: #{prompt}")
    else
      Rails.logger.error("Failed to generate audio for prompt: #{prompt}")
    end
  rescue StandardError => e
    Rails.logger.error("Error in TextToSpeechJob: #{e.message}")
  end
end
