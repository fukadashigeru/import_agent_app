document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-remove-form-for-set-items]')

  if (clicked) {
    const add_button = clicked.previousElementSibling;
    const extenalLinkBtn = add_button.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;
    
    extenalLinkBtn.remove();
    form.remove();

    // const parent = clicked.parentNode;
    
    // parent.insertBefore(formClone, clicked);
    // parent.insertBefore(extenalLinkBtnClone, clicked);

    clicked.classList.add('hidden');
    add_button.classList.remove('hidden');
  }
})
