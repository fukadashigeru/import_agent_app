export async function enter (element, { active, from, to }) {
  element.classList.remove('hidden')

  if (active) element.classList.add(...active)
  if (from) element.classList.add(...from)

  await nextFrame()

  if (from) element.classList.remove(...from)
  if (to) element.classList.add(...to)

  await afterTransition(element)

  if (to) element.classList.remove(...to)
  if (active) element.classList.remove(...active)
}

export async function leave (element, { start, from, to }) {
  if (start) element.classList.add(...start)
  if (from) element.classList.add(...from)

  await nextFrame()

  if (from) element.classList.remove(...from)
  if (to) element.classList.add(...to)

  await afterTransition(element)

  if (to) element.classList.remove(...to)
  if (start) element.classList.remove(...start)

  element.classList.add('hidden')
}

function nextFrame() {
  return new Promise(resolve => {
    requestAnimationFrame(() => {
      requestAnimationFrame(resolve)
    })
  })
}

function afterTransition(element) {
  return new Promise(resolve => {
    const duration = Number(
      getComputedStyle(element)
        .transitionDuration
        .replace('s', '')
    ) * 1000

    setTimeout(() => {
      resolve()
    }, duration)
  })
}
