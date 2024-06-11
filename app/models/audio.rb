class Audio < ApplicationRecord
  has_one_attached :file
  after_update_commit :broadcast_audio


  def broadcast_audio
    broadcast_update_to(
      'audio-stream',
      target: 'audio-container',
      partial: 'audio/audio_container',
      locals: { audio: self, autoplay: true }
    )
  end
end
