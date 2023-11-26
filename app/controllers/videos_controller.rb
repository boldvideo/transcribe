class VideosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_video_details]
  before_action :set_video, only: [:show, :show_json, :show_webvtt, :show_srt]

  require 'open-uri'
  require 'json'

  def new
    @uuid = SecureRandom.uuid
    @direct_upload_url = generate_mux_direct_upload_url(@uuid)
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
    @active_tab = 'json'
    @transcript_url = @video.json_transcription_url
  end

  def update_video_details
    video = Video.find(params[:id])
    if video.update(video_params)
      render json: { success: true }, status: :ok
    else
      render json: { errors: video.errors.full_messages }, status: :unprocessable_entity
    end
    
  end

  def show_json
    begin
      raw_json = fetch_file_content(@video.json_transcription_url)
      @transcript_content = JSON.pretty_generate(JSON.parse(raw_json))
    rescue JSON::ParserError => e
      @transcript_content = "Error parsing JSON: #{e.message}"
    end

    @active_tab = 'json'
    @transcript_url = @video.json_transcription_url

    render :show
  end

  def show_webvtt
    # @transcript_content = fetch_file_content(@video.webvtt_url)
    @active_tab = 'webvtt'
    @transcript_url = @video.webvtt_url

    render :show
  end

  def show_srt
    # @transcript_content = fetch_file_content(@video.srt_url)
    @active_tab = 'srt'
    @transcript_url = @video.srt_url

    render :show
  end

  def transcript_content
    if json_file?(params[:url])
      process_json_file(params[:url])
    else
      @transcript_content = fetch_file_content(params[:url])
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

  def json_file?(url)
    URI.parse(url).path.downcase.ends_with?('.json')
  end

  def process_json_file(url)
    begin
      raw_json = fetch_file_content(url)
      @transcript_content = JSON.pretty_generate(JSON.parse(raw_json))
    rescue JSON::ParserError => e
      @transcript_content = "Error parsing JSON: #{e.message}"
    rescue URI::InvalidURIError => e
      @transcript_content = "Invalid URL: #{e.message}"
    end
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def video_params
    params.require(:video).permit(:mux_asset_id, :playback_id, :status, :transcription_status, :file)
  end

  def fetch_file_content(url)
    URI.open(url).read
  rescue OpenURI::HTTPError => e
    "Error fetching file: #{e.message}"
  end

end
