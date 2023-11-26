class TranscriptionCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    logger.debug "Deepgram callback received."

    video = Video.find_by(transcript_request_id: params[:metadata][:request_id])

    if params.dig('results', 'utterances')
      s3_client = Aws::S3::Resource.new
      bucket = s3_client.bucket('bold-transcriber')

      json_key = "transcripts/#{video.id}/transcript.json"
      vtt_key = "transcripts/#{video.id}/transcript.vtt"
      srt_key = "transcripts/#{video.id}/transcript.srt"

      bucket.object(json_key).put(body: params.to_json)
      bucket.object(vtt_key).put(body: TranscriptionConverter.to_webvtt(params))
      bucket.object(srt_key).put(body: TranscriptionConverter.to_srt(params))

      video.update(
        json_transcription_url: bucket.object(json_key).public_url,
        webvtt_url: bucket.object(vtt_key).public_url,
        srt_url: bucket.object(srt_key).public_url,
        transcription_status: 'ready'
      )

      Turbo::StreamsChannel.broadcast_append_to(
        video, 
        target: "transcription_status",
        content: %(<turbo-stream action="redirect" href="#{show_json_path(video)}"></turbo-stream>)
      )

      # Turbo::StreamsChannel.broadcast_replace_to(video, 
      #                         target: "transcription_status", 
      #                         partial: "videos/transcription_status",
      #                         locals: { video: video })
      # Turbo::StreamsChannel.broadcast_append_to(video, 
      #                         target: "transcription_status", 
      #                         action: :update, 
      #                         content: turbo_stream_action_tag('redirect', url: show_json_path(video.id)))

    else
      logger.error("Utterances missing in transcription: #{params}")
    end

    head :ok 
  end
end
