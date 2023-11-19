class VideosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_video_details]

  def new
    uuid = SecureRandom.uuid
    @direct_upload_url = generate_mux_direct_upload_url(uuid)
  end

  def create
    @video = Video.new(video_params.merge(id: params[:uuid]))

    if @video.save
      render json: { uuid: @video.id }, status: :ok
    else
      render json: { errors: @video.errors.full_messages }, status: :unprocessable_entity
    end

  end

  def show
    @video = Video.find(params[:id])
  end

  def update_video_details
    video = Video.find(params[:id])
    if video.update(video_params)
      render json: { success: true }, status: :ok
    else
      render json: { errors: video.errors.full_messages }, status: :unprocessable_entity
    end
    
  end

  def generate_mux_direct_upload_url(uuid)
    MuxRuby.configure do |config|
      mux_credentials = Rails.application.credentials.dig(:mux)
      config.username = mux_credentials[:access_token_id]
      config.password = mux_credentials[:secret_key]
    end

    uploads_api = MuxRuby::DirectUploadsApi.new
    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
    create_asset_request.passthrough = uuid
    create_asset_request.mp4_support = "standard"

    create_upload_request = MuxRuby::CreateUploadRequest.new
    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.timeout = 3600
    create_upload_request.cors_origin = request.base_url

    upload = uploads_api.create_direct_upload(create_upload_request)

    logger.debug create_asset_request
    logger.debug upload.data
    logger.debug upload.data.new_asset_settings

    upload.data.url
  end

  private

  def video_params
    params.require(:video).permit(:mux_asset_id, :playback_id, :status, :transcription_status, :file)
  end

end
