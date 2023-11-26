module TranscriptionConverter
  def self.to_webvtt(transcription)
    unless transcription.dig('results', 'utterances')
    raise "Utterances are required for WebVTT conversion."
  end

    lines = [
      "WEBVTT", 
      "", 
      "NOTE",
      "Created: #{transcription['metadata']['created']}",
      "Duration: #{transcription['metadata']['duration']}",
      "Channels: #{transcription['metadata']['channels']}",
      ""
    ]

    transcription['results']['utterances'].each do |utterance|
      utterance['words'].each_slice(8) do |words|
        first_word, last_word = words.first, words.last
        lines << "#{seconds_to_timestamp(first_word['start'])} --> #{seconds_to_timestamp(last_word['end'])}"
        lines << words.map { |word| word['punctuated_word'] || word['word'] }.join(" ")
        lines << ""
      end
    end

    lines.join("\n")
  end

  def self.to_srt(transcription)
    unless transcription.dig('results', 'utterances')
      raise "Utterances are required for SRT conversion."
    end

    lines = []
    entry = 1

    transcription['results']['utterances'].each do |utterance|
      utterance['words'].each_slice(8) do |words|
        first_word, last_word = words.first, words.last
        lines << entry.to_s
        lines << "#{seconds_to_timestamp(first_word['start'], 'HH:MM:SS,mmm')} --> #{seconds_to_timestamp(last_word['end'], 'HH:MM:SS,mmm')}"
        lines << words.map { |word| word['punctuated_word'] || word['word'] }.join(" ")
        lines << ""
        entry += 1
      end
    end

    lines.join("\n")
  end

  private

  def self.seconds_to_timestamp(seconds, format = 'HH:MM:SS')
    hrs, seconds = seconds.divmod(3600)
    mins, secs = seconds.divmod(60)
    millisecs = ((secs - secs.floor) * 1000).round

    case format
      when 'HH:MM:SS,mmm'
        format('%02d:%02d:%02d,%03d', hrs, mins, secs, millisecs)
    else
      format('%02d:%02d:%02d.%03d', hrs, mins, secs, millisecs)
    end
  end
end

