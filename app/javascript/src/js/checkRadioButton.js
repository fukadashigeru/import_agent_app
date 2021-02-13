document.addEventListener('change', (e) => {
  const radioButtonTags = document.querySelectorAll('[data-firstpriority]');
  const checkedRadioButtonTagsBool = Array.from(radioButtonTags).some((element) => element.checked)

  if (!checkedRadioButtonTagsBool) {
    const table = document.getElementById('supplier-forms-table');
    const trs = table.querySelectorAll('tr');

    Array.from(trs).some((tr) => {
      const inputs = tr.querySelectorAll('[data-supplierform]');
      const inputsBool = Array.from(inputs).some((element) => element.value !== '')

      if (inputsBool) {
        tr.querySelector('[data-firstpriority]').checked = true;
        return true;
      }
    })
  }
})
