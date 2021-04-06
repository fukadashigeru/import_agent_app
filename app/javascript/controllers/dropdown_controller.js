import { Controller } from "stimulus"
import tippy from 'tippy.js'
import 'tippy.js/animations/perspective.css';

export default class extends Controller {
  static targets = [ "trigger", "dropdownPlace"]

  connect() {
    tippy(this.triggerTarget, {
      content: this.dropdownPlaceTarget.innerHTML,
      trigger: 'click',
      allowHTML: true,
      interactive: true,
      appendTo: () => document.body,
      animation: 'perspective',
      duration: 100,
      placement: 'bottom-end'
    })
    this.dropdownPlaceTarget.remove()
  }
}

