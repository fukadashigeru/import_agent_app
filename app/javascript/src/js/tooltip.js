import tippy from 'tippy.js'
import 'tippy.js/dist/tippy.css';

document.addEventListener('turbolinks:load', init)

export function init () {
  console.log('a')
  tippy('[data-tooltip]', {
    theme: 'tooltip',
    content: (e) => e.getAttribute('data-tooltip')
  })
}

document.addEventListener('mouseover', init_modal)

function init_modal () {
  const target = document.querySelector('[data-modal-tooltip]')
  if (target) {
    tippy(target, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip')
    })
  }
}
