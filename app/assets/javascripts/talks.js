jQuery.noConflict(); // so that Prototype and jQuery can coexist
(function($){
    $(document).ready(function() {
	$("[rel=tooltip]").tooltip();
    });
})(jQuery);


/** Behaviour rules to apply **/
var default_rules = {
	'td.flash div.error' : function(el){
		new Effect.Highlight(el,{duration:5.0, startcolor:'#ff0000'} );
	},
	'td.flash div.warning' : function(el){
		new Effect.Highlight(el,{duration:5.0, startcolor:'#f9ff0'});
	},
	'td.flash div.confirm' : function(el){
		new Effect.Highlight(el,{duration:5.0, startcolor:'#008934'});
	}
};

Behaviour.register(default_rules);

var leftbar_rules = {
	'input#search' : function(el){
		default_value(el,'Search');
	}
};

var tickle_rules = {
	'input#tickle_recipient_email' : function(el){
		default_value(el,"your friend's e-mail");
	}
};

var list_rules = {
};

var list_edit_rules = {
	'#editlist input#list_name' : function(el){ default_value(el,'Name to be confirmed'); },
	'#editlist textarea#list_details' : function(el){ default_value(el,'Description to be confirmed'); }
};

var list_new_rules = {
	'#editlist input#list_name' : function(el){ default_value(el,'Name to be confirmed'); },
	'#editlist textarea#list_details' : function(el){ default_value(el,'Description to be confirmed'); }
};

var add_list_rules = {
	'input#list_name' : function(el){
		default_value(el,'Type the title of a new list here');
	}
};

/** Helper functions **/

function default_value(el,text) {
	blurInputDefault(el,text);
	Event.observe(el, 'focus', function(event){ focusInputDefault(Event.element(event),text) });
	Event.observe(el, 'blur', function(event){ blurInputDefault(Event.element(event),text) });
}

function focusInputDefault(name,text) {
	if($(name).value == text) {
		Element.removeClassName(name,'blur');
		$(name).value = '';
	}
}

function blurInputDefault(name,text) {
	if($(name).value == '' ) {
		Element.addClassName(name,'blur');
		$(name).value = text;
	}
}

function setVenue(name,prefix) {
	setField(prefix+'venue_name',name);
}

function setSpeaker(name,email,prefix) {
	setField(prefix+'name_of_speaker',name);
	setField(prefix+'speaker_email',email);
}

function setTiming(start,finish,prefix) {
	setField(prefix+'start_time_string',start);
	setField(prefix+'end_time_string',finish);
}

function setField(field,value) {
	new Effect.Highlight(field,{duration:5.0});
	$(field).value = value;
	$(field).removeClassName(name,'blur');
	return false
}

(function($){
    $.fn.talk_helper = function (list_id, prefix) {
    return this.each(function () {
	var field_begin = (prefix=='talk_') ? 0 : 7;
	$(this).focus(function() {
            var pos=$(this).prevAll('h3:first').offset();
            var offset=$('#edit_talk_help').offset();
            $('#edit_talk_help').offset({top: pos.top, left: offset.left});
            $('#edit_talk_help').load('/talk/help?list_id='+list_id+'&field='+this.id.substring(field_begin)+'&prefix='+prefix);
	});
    });
    }
})(jQuery);
