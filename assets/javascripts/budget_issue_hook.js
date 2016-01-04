$(function () {
  var $hideLink = $("#hide-disabled-deliverables");
  var $showLink = $("#show-disabled-deliverables");

  var $select = $("#issue_deliverable_id");
  var select = $select[0];
  var hiddenIds = $select.data("disabled");

  var $fullOptions = $("#issue_deliverable_id option").clone();

  $("#issue_deliverable_id option").each(function removeDisabledOptions() {
    var $this = $(this);
    var deliverableId = Number($this.attr("value"));

    if (hiddenIds.indexOf(deliverableId) != -1) {
      $this.remove();
    }
  });

  var $filteredOptions = $("#issue_deliverable_id option").clone();

  var toggle = function toggle(newOptions, hiddenLink, shownLink) {
    var value = select.options[select.selectedIndex].value;
    var option;

    $select.children().remove();
    $select.append(newOptions);

    hiddenLink.show();
    shownLink.hide();

    for (var i = 0; i < select.options.length; i++) {
      option = select.options[i];

      if (option.value == value) {
        option.selected = true;
        return;
      }
    }
    select.options[0].selected = true;
  };

  $showLink.click(toggle.bind(null, $fullOptions, $hideLink, $showLink));
  $hideLink.click(toggle.bind(null, $filteredOptions, $showLink, $hideLink));
});
