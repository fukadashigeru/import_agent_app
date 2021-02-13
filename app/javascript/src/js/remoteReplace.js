import axios from 'axios'
import tippy from 'tippy.js'

document.addEventListener('click', async (e) => {
  const clicked = e.target.closest('[data-remote-replace]')
  if (clicked) {
    const data = JSON.parse(clicked.getAttribute('data-remote-replace'))
    const response = await axios.get(data.url)
    const html = response.data

    const target = document.getElementById(data.id)

    while(target.firstChild) {
      target.removeChild(target.firstChild);
    }

    target.insertAdjacentHTML('beforeend', html)
  }
})

