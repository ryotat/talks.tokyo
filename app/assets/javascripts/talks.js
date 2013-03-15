jQuery.noConflict(); // so that Prototype and jQuery can coexist
(function($){
    $(document).ready(function() {
	$('body').tooltip({
	    selector: "[rel*=tooltip]"
	});
	$("[rel*=talks-modal]").talks('modal');
	$("[rel*=talks-hidden-btn]").on({'mouseenter': function() {
	    $(this).children('a').css({"display":"inline"});
	}, "mouseleave": function() {
	    $(this).children('a').css({"display":"none"});
	}});
	$("[rel*=receive-json]").live(
	    'ajax:success', function(event, data, status, xhr) {
		var target=$(this).data('target');
		var close=$(this).data('close');
		$.fn.talks('show_flash', data, target, close);
	    });

	$("[rel*=observe]").talks('observe_form');
    });

    var methods = {
	default_value : function(text) {
	    this.talks('blurInputDefault',text);
	    this.focus( function(event){ $(this).talks('focusInputDefault',text); });
	    this.blur( function(event){ $(this).talks('blurInputDefault', text); });
	},
	focusInputDefault : function(text) {
	    if(this.val() == text) {
		this.removeClass('blur');
		this.val('');
	    }
	},
	blurInputDefault : function(text) {
	    if(this.val() == '' ) {
		this.addClass('blur');
		this.val(text);
	    }
	},
	setField : function(value) {
	    this.effect('highlight', {}, 1000);
	    this.val(value);
	},
	helper : function (list_id, prefix) {
	    return this.each(function () {
		var field_begin = (prefix=='talk_') ? 0 : 7;
		$(this).focus(function() {
		    var pos=$(this).offset();
		    var offset=$('#edit_talk_help').offset();
		    $('#edit_talk_help').offset({top: pos.top, left: offset.left});
		    $('#edit_talk_help').load('/talks/help?list_id='+list_id+'&field='+this.id.substring(field_begin)+'&prefix='+prefix);
		});
	    });
	},
	observer : function(action) {
	    var $this = this;
	    var typingTimer;              
	    var doneTypingInterval = 500;
	    var doneTyping = function() {
		action($this);
	    };
	    this.bind('keyup change',function() {
		clearTimeout(typingTimer);
		if ($this.val()) {
		    typingTimer = setTimeout(doneTyping, doneTypingInterval);
		}
	    });
	},
	observe_field : function(target, url) {
	    this.talks('observer', function($this) {
		$(target).load(url(encodeURIComponent($this.val())));
	    });
	},
	observe_form : function() {
	    var $this=this;
	    var target=this.data('target');
	    var url=this.data('observer-url');
	    this.find('input,textarea').talks('observer',function(el) {
		if (url.indexOf('.json') != -1) {
		    $.ajax({
			type: "POST",
			url: url,
			data: $this.serialize(),
			success: function(data) {
			    $.fn.talks('show_flash', data, target);
			}
		    });
		}
		else {
		    $(target).load(url, $this.serialize());
		}
	    });
	},
	show_flash: function(data, target, close) {
	    if (data.confirm) {
		$(target).html('<div class="alert alert-success">'+data.confirm+'</div>');
		$(target).effect('highlight', {}, 1000);
		if (close) {
		    $(close).leanModalClose();
		}
	    }
	    if (data.error) {
		$(target).html('<div class="alert alert-error">'+data.error+'</div>');
		$(target).effect('highlight', {}, 1000);
	    }
	},
	replace_button: function(content) {
	    this.tooltip('hide');
	    this.replaceWith(content);
	},
	calendar_with_talks : function(opt) {
	    var $this=this;
	    if (typeof(opt.dates)=='undefined') { opt.dates = []; }
	    if (typeof(opt.titles)=='undefined') { opt.titles = []; }
	    if (typeof(opt.date)=='undefined') { opt.date = ''; }
	    if (typeof(opt.trigger)=='undefined') { opt.trigger = 'click'; }
	    $this.datepicker({beforeShowDay: function(d) {
		var ind=[];
		$.each(opt.dates, function(i,e){ if ((e-d)==0) { ind.push(i); }});
		if (ind.length>0) {
		    var str="";
		    for( var i=0; i<ind.length; i++) {
			str+=opt.titles[ind[i]];
		    }
		    return [true, "highlight list%d_color".replace('%d',opt.ids[ind[0]]), encodeURIComponent(str)];
		}
		else {
		    return [true, ""];
		}
	    }, afterShow: function(inst) {
		inst.dpDiv.find('td.highlight').each(function() { 
		    var a = $(this).children('a');
		    a.tooltip({title: decodeURIComponent(this.title), html:true, trigger: opt.trigger});
		this.title='';});
	    }, onSelect: function(date, inst) {
		if (opt.trigger=='click') {
		    inst.inline = false;
		}
		var aogn=inst.dpDiv.find('a:hover');
		var a=inst.dpDiv.find('div.tooltip a');
		$(document).keyup(function(e){if(e.which==27){ aogn.tooltip('hide'); }});
		a.click(function() {
		    location.href = $(this).attr('href');
		});
	    }, dateFormat: 'yy/mm/dd'});
	    $this.datepicker("setDate",opt.date);
	},
	modal : function() {
	    this.live('click',function(e){
		var target='talks-modal';
		var href=$(this).attr('href');
		e.preventDefault();
		if ($('#'+target).length==0) {
		    $('body').append("<div id='%s' class='lean_modal'><button type='button' class='modal_close close'>&times;</button><div class='modal-body'></div></div>".replace('%s',target));
		}
		$('#'+target+' .modal-body').load(href);
		$('#'+target).leanModalShow({ top : 100, closeButton: ".modal_close"});
	    });
	}
    };
    $.fn.talks = function( method ) {
	// Method calling logic
	if ( methods[method] ) {
	    return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
	} else if ( typeof method === 'object' || ! method ) {
	    return methods.init.apply( this, arguments );
	} else {
	    $.error( 'Method ' +  method + ' does not exist on jQuery.talks' );
	}    
  };

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


var tickle_rules = {
	'input#tickle_recipient_email' : function(el){
	    jQuery(el).talks('default_value',"your friend's e-mail");
	}
};

var list_rules = {
};

var list_edit_rules = {
	'#editlist input#list_name' : function(el){ jQuery(el).talks('default_value','Name to be confirmed'); },
	'#editlist textarea#list_details' : function(el){ jQuery(el).talks('default_value','Description to be confirmed'); }
};

var list_new_rules = {
	'#editlist input#list_name' : function(el){ jQuery(el).talks('default_value','Name to be confirmed'); },
	'#editlist textarea#list_details' : function(el){ jQuery(el).talks('default_value','Description to be confirmed'); }
};


/** Helper functions **/

function setVenue(name,prefix) {
    jQuery('#'+prefix+'venue_name').talks('setField',name);
}

function setSpeaker(name,email,prefix) {
    jQuery('#'+prefix+'name_of_speaker').talks('setField',name);
    jQuery('#'+prefix+'speaker_email').talks('setField',email);
}

function setTiming(start,finish,prefix) {
    jQuery('#'+prefix+'start_time_string').talks('setField',start);
    jQuery('#'+prefix+'end_time_string').talks('setField',finish);
}


