document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-add-form-for-set-items]')

  if (clicked) {
    const remove_button = clicked.nextElementSibling;
    const extenalLinkBtn = clicked.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;
    
    const extenalLinkBtnClone = extenalLinkBtn.cloneNode(true);
    const formClone = form.cloneNode(true);
    formClone.value = null;

    const parent = clicked.parentNode;
    
    // parent.appendChild(formClone);
    // parent.appendChild(extenalLinkBtnClone);
    parent.insertBefore(formClone, clicked);
    parent.insertBefore(extenalLinkBtnClone, clicked);

    clicked.classList.add('hidden');
    remove_button.classList.remove('hidden');
  }
})
