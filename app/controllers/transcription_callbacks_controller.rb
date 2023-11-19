class TranscriptionCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # Log the data received from Deepgram
    logger.debug "Deepgram callback received."

    video = Video.find_by(transcript_request_id: params[:metadata][:request_id])

    if params.dig('results', 'utterances')
       s3_client = Aws::S3::Resource.new
      bucket = s3_client.bucket('bold-transcriber')

      # Save JSON
      json_key = "transcripts/#{video.id}/transcript.json"
      bucket.object(json_key).put(body: params.to_json)
      video.update(json_transcription_url: bucket.object(json_key).public_url)

      # Save WebVTT
      vtt_key = "transcripts/#{video.id}/transcript.vtt"
      bucket.object(vtt_key).put(body: TranscriptionConverter.to_webvtt(params))
      video.update(webvtt_url: bucket.object(vtt_key).public_url)

      # Save SRT
      srt_key = "transcripts/#{video.id}/transcript.srt"
      bucket.object(srt_key).put(body: TranscriptionConverter.to_srt(params))
      video.update(srt_url: bucket.object(srt_key).public_url)

    else
      logger.error("Utterances missing in transcription: #{params}")
    end

    head :ok # Send a 200 OK response to acknowledge receipt
  end
end
