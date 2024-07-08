class Audio < ApplicationRecord
  after_update_commit :broadcast_audio, if: :file_attached?
  has_one_attached :file

  private

  def file_attached?
    self.file.attached?
  end

  def broadcast_audio
    Turbo::StreamsChannel.broadcast_update_to(
      "audio-stream",
      target: "audio-#{id}-container",
      partial: "audio/audio_container",
      locals: { audio: self, autoplay: false }
    )
  end
end
