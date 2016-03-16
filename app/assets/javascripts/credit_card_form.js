$(function () {
    // Intercept the submit
    $(".cc_form").on('submit', submitHandler);

    // Set the dropdown correctly based on plan entered
    handlePlanChange(getURLParameter('plan'), ".cc_form");

    // Intercept the plan changing
    $("#tenant_plan").on('change', function () {
        handlePlanChange($("#tenant_plan :selected").val(), ".cc_form");
    });
});

// function to handle submission of form and intercept default event

function submitHandler(event) {
    var $form = $(event.target);

    $form.find('input[type=submit]').prop("disabled", true);

    if (Stripe) {
        Stripe.card.createToken($form, stripeResponseHandler);
    } else {
        showError("Failed to process. Please reload the page.");
    }
    return false;
}

// handle the event of plan drop-down changing

var handlePlanChange = function (plan_type, form) {
    var $form = $(form);

    if (plan_type == undefined) {
        plan_type = $('#tenant_plan :selected').val();
    }

    if (plan_type === 'premium') {
        $('[data-stripe]').prop('required', true);
        $form.off('submit');
        $form.on('submit', submitHandler);
        $('[data-stripe]').show();
    } else { // Free plan
        $('[data-stripe]').removeProp('required');
        $form.off('submit');
        $('[data-stripe]').hide();
    }
}

function getURLParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&');

    for (var i = 0; i < sURLVariables.length; ++i) {
        var sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] == sParam) {
            return sParameterName[1];
        }
    }
}


// Insert the token, but not the credit card details, into the data stream

function stripeResponseHandler(status, response) {
    var $form = $(".cc_form");

    if (response.error) {
        console.log(response.error.message);
        showError(response.error.message);

        $form.find('input[type=submit]').prop("disabled", false);
    } else {
        var token = response.id;
        $form.append($('<input type="hidden" name="payment[token]" />').val(token));
        $("[data-stripe=number]").remove();
        $("[data-stripe=cvv]").remove();
        $("[data-stripe=exp-year]").remove();
        $("[data-stripe=exp-month]").remove();
        $("[data-stripe=label]").remove();

        $form.get(0).submit();
    }
    return false;
}

// Show errors, if any

function showError(message) {
    if ($("#flash-messages").size() < 1) {
        $('div.container.main div:first').prepend("<div id='flash-messages'></div>")
    }

    $("#flash-messages").html('<div class="alert alert-warning"><a class="close" data-dismiss="alert">×</a><div id="flash_alert">' + message + '</div></div>');
    $('.alert').delay(5000).fadeOut(3000);

    return false;
}