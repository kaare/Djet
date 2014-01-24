function editHtml(elm) {
  switch($(elm).data('role')) {
    case 'h1':
    case 'h2':
    case 'p':
      document.execCommand('formatBlock', false, $(elm).data('role'));
      break;
    default:
      document.execCommand($(elm).data('role'), false, null);
      break;
    }
  $(elm).closest('.editHtml').next('.htmlEditor').focus();
}
$('.editHtml a').click(function(e) { editHtml(this) } )
