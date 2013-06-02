$(function() {
	// there's the gallery and the trash
	$(".trash li").draggable({
		cancel: "a.ui-icon", // clicking an icon won't initiate dragging
		revert: "invalid", // when not dropped, the item will revert back to its initial position
		containment: $( "#demo-frame" ).length ? "#demo-frame" : "document", // stick to demo-frame if present
		helper: "clone",
		cursor: "move"
	});
	var $gallery = $( "#gallery" ),
		$trash = $( ".trash" );

	// let the gallery items be draggable
	$( "li", $gallery ).draggable({
		cancel: "a.ui-icon", // clicking an icon won't initiate dragging
		revert: "invalid", // when not dropped, the item will revert back to its initial position
		containment: $( "#demo-frame" ).length ? "#demo-frame" : "document", // stick to demo-frame if present
		helper: "clone",
		cursor: "move"
	});

	$($gallery)
		.get(0)
		.addEventListener('drop', upload, false);

	function upload(event) { 
		alert('hej');
		/* Uploading will here. */
	}

	// let the trash be droppable, accepting the gallery items
	$trash.droppable({
		accept: "#gallery > li",
		activeClass: "ui-state-highlight",
		drop: function( event, ui ) {
			moveImage( ui.draggable, $(this) );
		}
	});

	// let the gallery be droppable as well, accepting items from the trash
	$gallery.droppable({
		accept: ".trash li",
		activeClass: "custom-state-active",
		drop: function( event, ui ) {
			recycleImage( ui.draggable );
		}
	});

	// image deletion function
	var recycle_icon = "<a href='link/to/recycle/script/when/we/have/js/off' title='Recycle this image' class='ui-icon ui-icon-refresh'>Recycle image</a>";
	function moveImage( $item, $togrp ) {
		$item.fadeOut(function() {
			var $list = $( "ul", $togrp ).length ?
				$( "ul", $togrp ) :
				$( "<ul class='gallery ui-helper-reset'/>" ).appendTo( $togrp );

			$item.find( "a.ui-icon-trash" ).remove();
			$item.append( recycle_icon ).appendTo( $list ).fadeIn(function() {
				$item
					.animate({ width: "48px" })
					.find( "img" )
						.animate({ height: "36px" });
			})
			.css({"position":"relative", "left": "0px", "top": "0px", "width": "96px"})
			;
		});

		var url = $togrp.attr('id').split(':')[1];
		var data = JSON.stringify({photo_id: $item.attr('id')});
		$.ajax({
			url: url,
			contentType: 'application/json',
			type: 'POST',
			data: data
		})

	}

	// image recycle function
	var trash_icon = "<a href='link/to/trash/script/when/we/have/js/off' title='Delete this image' class='ui-icon ui-icon-trash'>Delete image</a>";
	function recycleImage( $item ) {
		$item.fadeOut(function() {
			$item
				.find( "a.ui-icon-refresh" )
				.remove()
				.end()
				.css({"position":"relative", "left": "0px", "top": "0px", "width": "96px"})
				.append( trash_icon )
				.find( "img" )
				.css( "height", "72px" )
				.end()
				.appendTo( $gallery )
				.fadeIn();
		});

		var url = 'scratch';
		var data = JSON.stringify({photo_id: $item.attr('id')});
		$.ajax({
			url: url,
			contentType: 'application/json',
			type: 'POST',
			data: data
		})
	}

	// image preview function, demonstrating the ui.dialog used as a modal window
	function viewLargerImage( $link ) {
		var src = $link.attr( "href" ),
			title = $link.siblings( "img" ).attr( "alt" ),
			$modal = $( "img[src$='" + src + "']" );

		if ( $modal.length ) {
			$modal.dialog();
		} else {
			var img = $( "<img alt='" + title + "' width='384' height='288' style='display: none; padding: 8px;' />" )
				.attr( "src", src ).appendTo( "body" );
			setTimeout(function() {
				img.dialog({
					title: title,
					width: 400,
					modal: true
				});
			}, 1 );
		}
	}

	// resolve the icons behavior with event delegation
	$( "ul.gallery > li" ).click(function( event ) {
		var $item = $( this ),
			$target = $( event.target );

		if ( $target.is( "a.ui-icon-trash" ) ) {
			moveImage( $item, $(this) );
		} else if ( $target.is( "a.ui-icon-zoomin" ) ) {
			viewLargerImage( $target );
		} else if ( $target.is( "a.ui-icon-refresh" ) ) {
			recycleImage( $item );
		}

		return false;
	});
});
