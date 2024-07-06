class Audio < ApplicationRecord
  after_commit :broadcast_audio, on: [:create], if: :file_attached?
  has_one_attached :file

  private

  def file_attached?
    self.file.attached?
  end

  def broadcast_audio
    Turbo::StreamsChannel.broadcast_append_to(
      "audio-stream",
      target: "audio-container",
      partial: "audio/audio_container",
      locals: { audio: self, autoplay: false }
    )
  end
end
