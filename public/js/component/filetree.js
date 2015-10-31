	$('.djet_file_chooser').fileTree({ script: '/jqueryFileTree' }, function(file) {
			var fa = file.split(/[/.]/);
			var fa_length = fa.length;
			var ext = fa[fa_length - 1];
			if (typeof(ext) != 'undefined' && ext.match(/jpg|png/)) {
					var imagename = '';
					for (var i=2;i<fa_length - 1;i++) {
							imagename = imagename + '/' + fa[i];
					}
					var thumbname = imagename + '_150x100.' + ext;
					var imagename = imagename + '.' + ext;
					$('.djet_file_image').attr('src', thumbname);
					$('.djet_file_name').html(imagename);
			}
	});
