var MTWI = {};

MTWI.forms = {
	signIn : function(o) {
		// Gets which service we're trying to sign in as; stored in the data-service attribute of the logo image
		var service = $(o).data('service');
		
		// Show the sign in form
		$('#sign-in > div').show();
		
		// Hide whichever sign in services weren't selected
		$('#sign-in > img').each(function() {
			if($(this).data('service') !== service) {
				$(this).hide();
			}
		});

		// Use this to change the action on the form
		// $('#form-sign-in').attr('action');
	},
	resetSignIn : function() {
		$('#sign-in > img').show();
		$('#sign-in > div').hide();
	},
	modalSignIn : function() {
		$('#action > div').hide();
		$('#sign-in').show();
	}
};

MTWI.sell = {
	modalSell : function() {
		$('#action > div').hide();
		$('#sell').show();
	}
};

MTWI.buy = {
	modalBuy : function() {
		$('#action > div').hide();
		$('#buy').show();
	}
};

$(document).ready(function() {
	$('#sign-in > img').click(function() {
		MTWI.forms.signIn(this);
	});
	
	$('#reset-sign-in').click(function() {
		MTWI.forms.resetSignIn();
	});
	
	$('#sell-button').click(function() {
		// if signed in
		MTWI.sell.modalSell();
		// else MTWI.forms.modalSignIn()
	});
	
	$('#buy-button').click(function() {
		// if signed in
		MTWI.buy.modalBuy();
		// else MTWI.forms.modalSignIn()
	});
});