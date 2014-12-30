var prevh = 4;
var h;
function sticky_relocate() {
    var window_top = $(window).scrollTop();
    var div_top = $('#sticky-anchor').offset().top;
    if (window_top > div_top) {
        $('#nav').addClass('stick');
    } else {
        $('#nav').removeClass('stick');
    }
}

$(function () {
    $(window).scroll(sticky_relocate);
    sticky_relocate();
});
window.setInterval(function() {if(h!=prevh) {
	console.log("changed!");
	prevh = h;
}}
, 100);


