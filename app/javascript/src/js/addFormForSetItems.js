document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-form-for-set-items]')

  if (clicked) {
    const extenalLinkBtn = clicked.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;
    
    const extenalLinkBtnClone = extenalLinkBtn.cloneNode(true);
    const formClone = form.cloneNode(true);
    formClone.value = null;

    const parent = clicked.parentNode;
    
    parent.appendChild(formClone);
    parent.appendChild(extenalLinkBtnClone);

    clicked.remove();
  }
})
