function initUploader() {
  const uploader = document.querySelector('mux-uploader');
  let videoId;
  if (uploader) {

    videoId = uploader.dataset.uuid;

    uploader.addEventListener('uploadstart', function() {
      // create record when upload starts
      fetch('/videos/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          uuid: videoId,
          status: 'encoding',
          transcription_status: 'waiting'
        })
      }).then(response => {
        if (response.ok) {
          console.log('video created')
        } else {
          console.log('error', response)
        }
      });

    })
    uploader.addEventListener('success', function() {
      window.location.href = `/${videoId}`;
    });
  } else {
    console.log('no uploader')
  }

}
document.addEventListener('turbo:load', initUploader);
document.addEventListener('DOMContentLoaded', initUploader);

