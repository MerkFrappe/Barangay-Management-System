var donate = '<form style="position:absolute; left:100px; top:5px;"  action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_blank">' +
    '<input type="hidden" name="cmd" value="_s-xclick">' +
    '<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----' +
    '">' +
    '<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">' +
    '<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">' +
    '</form>';




var strVar = "";
strVar += " <div id=\"ird\" style=\"position:fixed; opacity:1; width:100%; top:0; left:0; background-color:rgba(72, 155, 219, 1); color:white; box-shadow:5px 5px 50px #efefef;   z-index:99999999999999; height:55px; font-family:tahoma;  \">";
strVar += "  <span id=\"donate\">  </span>  <h2 style=\"text-align:center; color:white; font-size:18px; font-weight:500; margin:0; margin-top:17px;\">  Facebook Messages Cleaner <small> ( <span id='num'> ........... </span>  )</small>";
strVar += "	  <\/h2>";
strVar += "  <button id=\"btnclose\" style=\"float:right; margin-right:40px; cursor:pointer; background-color:#d9534f; color:white; border:1px solid maroon; margin-top:-25px; border-radius:5px; padding:4px; font-size:15px;\"> Close </button>";
strVar += "  <\/div>";


var dm = 0;


if ($("#ird").length < 1) {
    $("html").prepend(strVar);
    // $("#donate").html(donate);
}


$("#btnclose").on("click", function() {
    window.location.reload();
})



var tt = 0;

var ssm = setInterval(function() {
    tt++;
    //	 var pt = document.querySelectorAll('[data-pagelet="MWThreadList"]')[0];
    //	 $(pt).scrollTop(pt.scrollHeight);
    $("#num").text("Gettting " +  getMessagesEls().length + " Messages. Please wait.");
    if (tt == 5) {
        deletefbmessage();
        clearInterval(ssm);
    }
}, 500);


function deletefbmessage() {

    var elms = getMessagesEls().eq(0);

    var button = elms.find('.x1k54i6l.xi81zsa');

    if (button.length) {
        button.eq(0).trigger("click");

        var s2 = setInterval(function() {
            var deleteBtn = $('[role="menuitem"]:contains("Delete")').eq(0);
            var isGroup = $('[role="menuitem"]:contains("Leave chat")').length;

            if (isGroup) {
                elms.attr('dfmsgs',true);
                button.eq(0).trigger("click");
                clearInterval(s2);
                setTimeout(deletefbmessage,1000);
                return;
            }

            if (deleteBtn.length) {
                deleteBtn.trigger("click");
                clearInterval(s2);

                var s3 = setInterval(function() {
                    var b3 = $('.n75z76so.ed17d2qt:contains("Delete Conversation"),.x1s688f.xtk6v10:contains("Delete")');

                    if (b3.length) {
                        clearInterval(s3);
                        elms.attr("dfmsgs", true);
                        b3.trigger("click");
                        dm++;

                        setTimeout(function() {
                            deletefbmessage();
                        }, 2000);
                        $("#num").text(dm + " Messages Deleted.");
                        chrome.storage.local.get("license_key",function(l){
                          if(!l.license_key){
                            if(dm == 20){
                              alert("You can only delete 20 messages in the free version. Please subscribe to delete unlimited messages.");
                              window.location.href = "https://gum.co/dfmsgs";
                            }
                          }
                        })
                    }
                }, 500);
            }
        }, 500);

    } else {
        $("#num").text("Delete Finished. " + dm + " Messages were Deleted.");
    }
}

function getMessagesEls(){
    var re = new RegExp("/messages(/.*)?/t/","i");
    var els = [];
    $("a[href*='/messages/']").each(function() {
        if(re.test($(this).attr('href'))){
            var parent = $(this).parents('[role="row"]').eq(0);
            if(parent.css("visibility") != "hidden" && !parent.attr('dfmsgs')){
                els.push(parent[0]);
            }
        }
    });
    return $(els);
}

