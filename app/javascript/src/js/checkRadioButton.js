document.addEventListener('remoteReplaceDone', function(){
  changeBgColor()
})

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

    changeBgColor()
  }
})

document.addEventListener('change', (e) => {
  const checkBtn = e.target.closest('[data-firstpriority]')
  if (checkBtn) {
    changeBgColor()
  } 
})

function changeBgColor() {
  const trs = document.querySelectorAll('[data-supplier-form-tr]')
  console.log(trs)
  Array.from(trs).forEach((tr) => {
    if(tr.querySelector('[data-firstpriority]').checked) {
      tr.classList.add('bg-blue-100')
    } else {
      tr.classList.remove('bg-blue-100')
    }
  })
 }
