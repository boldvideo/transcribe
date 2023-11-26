import { Turbo } from "@hotwired/turbo-rails"

document.addEventListener('turbo:load', () => {
  document.addEventListener('turbo:before-stream-render', event => {
    if (event.target.action === 'redirect' && event.target.getAttribute('href')) {
      Turbo.visit(event.target.getAttribute('href'));
      event.preventDefault();
    }
  });
});
