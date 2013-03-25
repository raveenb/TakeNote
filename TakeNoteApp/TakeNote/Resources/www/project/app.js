/*
 * JS for app generated by Tiggzi
 *
 * Created on: Monday, March 25, 2013, 11:06:46 AM (PDT)
 */
/************************************
 * JS API provided by Exadel Tiggzi  *
 ************************************/
/* Setting project environment indicator */
Tiggzi.env = "apk";
Tiggzi.getProjectGUID = function() {
    return '9236a0de-d14c-4076-933d-9f1d48d659aa';
}
Tiggzi.getTargetPlatform = function() {
    return 'I';
}

function navigateTo(outcome, useAjax) {
    Tiggzi.navigateTo(outcome, useAjax);
}

function adjustContentHeight() {
    Tiggzi.adjustContentHeight();
}

function adjustContentHeightWithPadding() {
    Tiggzi.adjustContentHeightWithPadding();
}

function setDetailContent(pageUrl) {
    Tiggzi.setDetailContent(pageUrl);
}
/**********************
 * SECURITY CONTEXTS  *
 **********************/
/*******************************
 *      SERVICE SETTINGS        *
 ********************************/
var SinglySettings = {
    "client_id": "",
    "client_secret": ""
}
/*************************
 *      SERVICES          *
 *************************/
var SinglySocialData = new Tiggr.RestService({
    'url': 'https://api.singly.com/profile',
    'dataType': 'json',
    'type': 'get',
});
var SinglyAccessToken = new Tiggr.RestService({
    'url': 'https://api.singly.com/oauth/access_token',
    'dataType': 'json',
    'type': 'post',
    'contentType': 'application/json',
    'serviceSettings': SinglySettings
});
createSpinner("res/lib/jquerymobile/images/ajax-loader.gif");
Tiggzi.AppPages = [{
    "name": "startScreen",
    "location": "startScreen.html"
}, {
    "name": "app",
    "location": "app.html"
}, {
    "name": "Capture",
    "location": "Capture.html"
}];
j_12_js = function(runBeforeShow) { /* Object & array with components "name-to-id" mapping */
    var n2id_buf = {
        'mobilesearchbar1_13': 'j_26',
        'mobilecollapsiblesetbean1_3': 'j_16',
        'mobilecollapsblock1_4': 'j_17',
        'mobilecollapsblockheader1_5': 'j_18',
        'mobilecollapsblockcontent1_6': 'j_19',
        'mobilecollapsblock1_7': 'j_20',
        'mobilecollapsblockheader1_8': 'j_21',
        'mobilecollapsblockcontent1_9': 'j_22',
        'mobilecollapsblock1_10': 'j_23',
        'mobilecollapsblockheader1_11': 'j_24',
        'mobilecollapsblockcontent1_12': 'j_25',
        'mobilenavbar2_16': 'j_28',
        'mobilenavbaritem4_17': 'j_29',
        'mobilenavbaritem4_18': 'j_30',
        'mobilenavbaritem4_19': 'j_31'
    };
    if ("n2id" in window && window.n2id !== undefined) {
        $.extend(n2id, n2id_buf);
    } else {
        window.n2id = n2id_buf;
    }
    Tiggr.CurrentScreen = 'j_12';
    /*************************
     * NONVISUAL COMPONENTS  *
     *************************/
    var datasources = [];
    // Tiggzi Push-notification registration service
    /************************
     * EVENTS AND HANDLERS  *
     ************************/
    j_12_beforeshow = function() {
        Tiggzi.CurrentScreen = 'j_12';
        for (var idx = 0; idx < datasources.length; idx++) {
            datasources[idx].__setupDisplay();
        }
    }
    // screen onload
    screen_163B_onLoad = j_12_onLoad = function() {
        screen_163B_elementsExtraJS();
        j_12_deviceEvents();
        j_12_windowEvents();
        screen_163B_elementsEvents();
    }
    // screen window events
    screen_163B_windowEvents = j_12_windowEvents = function() {
        $('#j_12').bind('pageshow orientationchange', function() {
            adjustContentHeightWithPadding();
        });
    }
    // device events
    j_12_deviceEvents = function() {
        document.addEventListener("deviceready", function() {});
    }
    // screen elements extra js
    screen_163B_elementsExtraJS = j_12_elementsExtraJS = function() {
        // screen (screen-163B) extra code
        /* mobilecollapsblock1 */
        $("#j_17 .ui-collapsible-heading-toggle").attr("tabindex", "2"); /* mobilecollapsblock2 */
        $("#j_20 .ui-collapsible-heading-toggle").attr("tabindex", "3"); /* mobilecollapsblock3 */
        $("#j_23 .ui-collapsible-heading-toggle").attr("tabindex", "4");
    }
    // screen elements handler
    screen_163B_elementsEvents = j_12_elementsEvents = function() {
        $("a :input,a a,a fieldset label").live({
            click: function(event) {
                event.stopPropagation();
            }
        });
    }
    $("#j_12").die("pagebeforeshow").live("pagebeforeshow", function(event, ui) {
        j_12_beforeshow();
    });
    if (runBeforeShow) {
        j_12_beforeshow();
    } else {
        j_12_onLoad();
    }
}
$("#j_12").die("pageinit").live("pageinit", function(event, ui) {
    Tiggzi.processSelectMenu($(this));
    j_12_js();
});