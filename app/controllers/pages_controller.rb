class PagesController < ApplicationController
  def home
    @audio = Audio.all.order(created_at: :desc)
  end
end
