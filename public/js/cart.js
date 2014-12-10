$(function() {
	// there's the gallery and the trash
	$(".add-to-basket").click(function() {
		var data = $(this).data();
		if (data.fixed != 1) {
			var qty = $("#basket-add-quantity-" + data.sku + " input").val()
				data.qty = qty;
		}
		$.post(
			$("#cart_url").text(),
			data,
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
