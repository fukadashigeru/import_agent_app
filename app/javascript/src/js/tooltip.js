import tippy from 'tippy.js'

document.addEventListener('turbolinks:load', init)

export function init () {
  tippy('[data-tooltip]', {
    theme: 'tooltip',
    content: (e) => e.getAttribute('data-tooltip')
  })
}

document.addEventListener('mouseover', init_modal)

function init_modal () {
  const targetA = document.querySelector('[data-modal-tooltip-a]')
  const targetB = document.querySelector('[data-modal-tooltip-b]')
  const targetC = document.querySelector('[data-modal-tooltip-c]')
  if (targetA || targetB || targetC) {
    tippy(targetA, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip-a')
    })
    tippy(targetB, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip-b')
    })
    tippy(targetC, {
      theme: 'tooltip',
      content: (e) => e.getAttribute('data-modal-tooltip-c')
    })
  }
}
