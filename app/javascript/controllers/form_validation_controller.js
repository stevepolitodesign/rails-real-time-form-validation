import Rails from "@rails/ujs"
import { Controller } from "stimulus"

export default class extends Controller {
  static targets  = [ "form", "output"]
  static values   = { url: String }

  handleChange(event) {
    let input = event.target
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
        input = document.getElementById(input.id);
        input.focus();
      },
    })
  }
}
