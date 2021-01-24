document.addEventListener('turbolinks:load', init)

function init () {
  let companies = document.getElementsByClassName('company');
  console.log(companies);
  for (var i = 0, len = companies.length; i < len; i++) {
    let company = companies[i];
    company.addEventListener('mouseenter', (e) => {
      company.querySelector('.company-sign-in').classList.add('text-gray-900');
    });
    company.addEventListener('mouseleave', (e) => {
      company.querySelector('.company-sign-in').classList.remove('text-gray-900');
    });
  }
}
