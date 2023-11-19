class VideoProcessingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    video = Video.find(video_id)
    # Mux API
    MuxRuby.configure do |config|
      mux_credentials = Rails.application.credentials.dig(:mux)
      config.username = mux_credentials[:access_token_id]
      config.password = mux_credentials[:secret_key]
    end

    uploads_api = MuxRuby::DirectUploadsApi.new

    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
    
    create_upload_request = MuxRuby::CreateUploadRequest.new
    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.cors_origin = "bold.eu.ngrok.io" # Update this

    upload = uploads_api.create_direct_upload(create_upload_request)
    
    if upload
      video.update(
        mux_asset_id: upload.data.id,
        # Store other relevant details if needed
      )
    end
  end
end
