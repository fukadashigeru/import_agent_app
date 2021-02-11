document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-external-link]')

  if (clicked) {
    const input = clicked.previousElementSibling;
    const url = input.value;
    if (url) {
      window.open(url);
    }
  }
})
