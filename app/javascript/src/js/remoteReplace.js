import axios from 'axios'

document.addEventListener('click', async (e) => {
  const clicked = e.target.closest('[data-remote-replace]')
  console.log(clicked)
  if (clicked) {
    const data = JSON.parse(clicked.getAttribute('data-remote-replace'))

    const response = await axios.get(data.url)
    console.log(response)
    const html = response.data

    const target = document.getElementById(data.id)

    // いらない子を削除
    target.childNodes.forEach((element) => {
      element.remove()
    })

    target.insertAdjacentHTML('beforeend', html)
  }
})

