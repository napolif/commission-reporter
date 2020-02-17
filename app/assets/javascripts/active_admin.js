//= require active_admin/base

function handlePdfCheckbox($checkbox, paramName) {
  handleCheckbox($checkbox, ".js-pdfLink", paramName)
}

function handleHtmlCheckbox($checkbox, paramName) {
  handleCheckbox($checkbox, ".js-htmlLink", paramName)
}

function handleCheckbox($checkbox, targetClass, paramName) {
  $checkbox.on("click", function() {

    $(targetClass).each((idx, link) => {
      const checked = $checkbox.is(":checked")
      let [url, initialParams] = link.href.split("?")
      let params = new URLSearchParams(initialParams)

      params.set(paramName, checked)
      link.href = url + "?" + params.toString()
    })
  })
}

function main() {
  handleHtmlCheckbox($(".js-listDisabledReps"), "list_disabled_reps")

  handlePdfCheckbox($(".js-grayscale"), "grayscale")
  handlePdfCheckbox($(".js-onePerPage"), "one_per_page")
  handlePdfCheckbox($(".js-listDisabledReps"), "list_disabled_reps")
}

$(document).ready(main)
