$(function() {
	// there's the gallery and the trash
	$(".add-to-basket").click(function() {
		$.post(
			'/cart',
			$(this).data(),
			function (data) {
				// Update minicart
				var minicart = jQuery.parseJSON( data );
				$('#minicart-quantity').text(minicart.quantity);
				$('#minicart-total').text(minicart.total);
			}
		);
	});
});
