document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-add-form-for-set-items]')

  if (clicked) {
    const add_button = clicked
    const remove_button = clicked.previousElementSibling;
    const extenalLinkBtn = remove_button.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;
    
    const extenalLinkBtnClone = extenalLinkBtn.cloneNode(true);
    const formClone = form.cloneNode(true);
    formClone.value = null;

    const parent = clicked.parentNode;
    parent.insertBefore(formClone, remove_button);
    parent.insertBefore(extenalLinkBtnClone, remove_button);

    const input_length = parent.getElementsByTagName('input').length;
    if (input_length >= 3) {
      add_button.classList.add('hidden');
    }
    if (input_length > 1 ) {
      remove_button.classList.remove('hidden');
    }
  }
})
