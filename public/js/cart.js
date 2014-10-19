$(function() {
	// there's the gallery and the trash
	$(".add-to-basket").click(function() {
		$.post(
			$("#cart_url").text(),
			$(this).data(),
			function (data) {
				// Show minicart
				$('#minicart').removeClass('hidden');
				// Update minicart
				var minicart = jQuery.parseJSON( data );
				$('#minicart-quantity').text(minicart.quantity);
				$('#minicart-total').text(minicart.total);
			}
		);
	});
});
