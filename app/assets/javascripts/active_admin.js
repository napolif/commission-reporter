//= require active_admin/base

function handlePdfCheckbox($checkbox, paramName) {
  $checkbox.on("click", function() {

    $(".js-pdfLink").each((idx, link) => {
      const checked = $checkbox.is(":checked")
      let [url, initialParams] = link.href.split("?")
      let params = new URLSearchParams(initialParams)

      params.set(paramName, checked)
      link.href = url + "?" + params.toString()
    })
  })
}

function main() {
  handlePdfCheckbox($(".js-grayscale"), "grayscale")
  handlePdfCheckbox($(".js-onePerPage"), "one_per_page")
}

$(document).ready(main)
