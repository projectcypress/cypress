import { Controller } from "@hotwired/stimulus"
import "parsleyjs" // ensures window.Parsley is available (depending on your setup)

let validatorsRegistered = false

export default class extends Controller {
  connect() {
    this.registerValidatorsOnce()

    // Initialize Parsley on the form (or re-use existing instance)
    this.parsley = window.jQuery(this.element).parsley()
  }

  disconnect() {
    if (this.parsley) this.parsley.destroy()
  }

  registerValidatorsOnce() {
    if (validatorsRegistered) return
    validatorsRegistered = true

    window.Parsley.addValidator("passwordcomplexity", {
      requirementType: "regexp",
      validateString(value, requirement) {
        let matches = 0
        ;[/\d/, /[A-Z]/, /[a-z]/, /[\W]/].forEach((pattern) => {
          if (value.match(pattern)) matches++
        })
        return matches >= 3
      },
      messages: {
        en: "Does not have at least 3 of the specified character types."
      }
    })

    window.Parsley.addValidator("phonenumber", {
      requirementType: "regexp",
      validateString(value, requirement) {
        return value.search(/[A-Za-z]/) === -1
      },
      messages: {
        en: "This value may not contain letters."
      }
    })
  }
}
