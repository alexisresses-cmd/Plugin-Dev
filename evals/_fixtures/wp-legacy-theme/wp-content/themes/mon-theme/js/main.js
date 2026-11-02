jQuery( function ( $ ) {
	$( '.mt-subscribe-form' ).on( 'submit', function ( event ) {
		event.preventDefault();
		var $form = $( this );
		$.post( mtAjax.url, {
			action: 'mt_subscribe',
			nonce: mtAjax.nonce,
			email: $form.find( '[name="email"]' ).val(),
			event_type: $form.find( '[name="event_type"]' ).val()
		} ).always( function ( response ) {
			var data = response.responseJSON || response;
			$form.find( '.mt-subscribe-message' ).text( data.data ? data.data.message : '' );
		} );
	} );
} );
