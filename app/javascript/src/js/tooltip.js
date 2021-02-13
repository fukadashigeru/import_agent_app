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
  const targetA = document.querySelector('[data-modal-tooltip-a]')
  const targetB = document.querySelector('[data-modal-tooltip-b]')
  if (targetA || targetB) {
    tippy(targetA, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip-a')
    })
    tippy(targetB, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip-b')
    })
  }
}
