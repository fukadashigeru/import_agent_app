document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-remove-form-for-set-items]')

  if (clicked) {
    const add_button = clicked.previousElementSibling;
    const extenalLinkBtn = add_button.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;

    if (form.value == '') {
      extenalLinkBtn.remove();
      form.remove();
      clicked.classList.add('hidden');
      add_button.classList.remove('hidden');
    } else {
      const res = confirm('2つめのフォームが削除されますがよろしいですか？（入力内容も削除されます。）');
      if (res == true) {
        extenalLinkBtn.remove();
        form.remove();
        clicked.classList.add('hidden');
        add_button.classList.remove('hidden');
      }
    }
  }
})

