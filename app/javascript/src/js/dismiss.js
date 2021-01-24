document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-dismiss]')

  if (clicked) {
    const targetSelector = clicked.getAttribute('data-dismiss')
    const target = document.querySelector(targetSelector)

    if (target) fadeOut(target)
  }
})

function fadeOut (element) {
  element.style.transition = 'opacity .14s ease-out'
  element.style.opacity = '0'
  element.addEventListener('transitionend', (e) => {
    if (e.target === element && e.propertyName === 'opacity') {
      element.remove()
    }
  })
}
