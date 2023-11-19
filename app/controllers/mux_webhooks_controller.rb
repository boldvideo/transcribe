class MuxWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    webhook_data = JSON.parse(request.body.read)

    case webhook_data['type']
      when 'video.asset.created'
        handle_asset_created(webhook_data)
      when 'video.asset.ready'
        handle_asset_ready(webhook_data)
      when 'video.asset.static_renditions.ready'
        handle_static_renditions_ready(webhook_data)
    end

    head :ok
  end

  private

  def handle_asset_created(data)
    uuid = data['data']['passthrough']
    # create video here
    logger.debug("ASSET CREATED")
  end

  def handle_asset_ready(data)
    uuid = data['data']['passthrough']
    video = Video.find_by(id: uuid)

    if video
      video.update(
        mux_asset_id: data['data']['id'],
        playback_id: data['data']['playback_ids'].first['id'],
        status: 'done'
      )
      if video.save
        logger.debug("BROADCASTING ---- TO #{video.id}")
        # VideoChannel.broadcast_to(video, "TEST")
        VideoChannel.broadcast_to(video, { status: video.status, playback_id: video.playback_id })
      end
    else
      logger.error "Video not found for UUID: #{uuid}"
    end
  end

  def handle_static_renditions_ready(data)
    video = Video.find_by(mux_asset_id: data['data']['id'])
    return unless video

    # always grab lowest qual video
    low_mp4 = data['data']['static_renditions']['files'].min_by { |file| file['bitrate'] }
    initiate_transcription(video, low_mp4)
  end

  def initiate_transcription(video, mp4_file)
    mp4_url = "https://stream.mux.com/#{video.playback_id}/#{mp4_file['name']}?download=#{mp4_file['name']}"

    # initiate transcription, store request ID on video for identifying video later
    transcription_response = Transcription.transcribe_audio(mp4_url)
    transcript_request_id = transcription_response['request_id']

    video.update(mp4_filename: mp4_file['name'], mp4_url: mp4_url, transcript_request_id: transcript_request_id, transcription_status: "transcribing")

    logger.debug("Video updated with mp4 and Transcript Request ID")

  end
end
