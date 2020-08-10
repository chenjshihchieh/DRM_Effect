$(document).keyup(function(event) {
  if ($("#recallInput").is(":focus") && (event.key == "Enter")) {
    $("#add").click();

  }
});
