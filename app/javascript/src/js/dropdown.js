import tippy from 'tippy.js'
import 'tippy.js/animations/perspective.css';

document.addEventListener('turbolinks:load', init)

function init () {
  tippy('[data-dropdown]', {
    content (ref) {
      if (!ref.dataset.dropdownTemplate) {
        const id = ref.getAttribute('data-dropdown')
        const template = document.getElementById(id)
        ref.dataset.dropdownTemplate = template.innerHTML
        template.remove()
      }
      return ref.dataset.dropdownTemplate
    },
    trigger: 'click',
    allowHTML: true,
    interactive: true,
    appendTo: () => document.body,
    animation: 'perspective',
    duration: 100,
    placement: 'bottom-end'
  })
}
