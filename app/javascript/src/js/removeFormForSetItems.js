document.addEventListener('click', (e) => {
  const clicked = e.target.closest('[data-remove-form-for-set-items]')

  if (clicked) {
    const add_button = clicked.nextElementSibling;
    const remove_button = clicked
    const extenalLinkBtn = clicked.previousElementSibling;
    const form = extenalLinkBtn.previousElementSibling;
    const parent = clicked.parentNode;

    if (form.value == '') {
      extenalLinkBtn.remove();
      form.remove();
    } else {
      const res = confirm('一番右のフォームが削除されますがよろしいですか？（入力内容も削除されます。）');
      if (res == true) {
        extenalLinkBtn.remove();
        form.remove();
      }
    }

    const input_length = parent.getElementsByTagName('input').length;
    if (input_length < 3) {
      add_button.classList.remove('hidden');
    }
    if (input_length <= 1 ) {
      remove_button.classList.add('hidden');
    }
  }
})

