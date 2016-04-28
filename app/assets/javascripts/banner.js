function init() {
  window.addEventListener('scroll', function(e){
    var distanceY = window.pageYOffset || document.documentElement.scrollTop;
    var shrinkOn = 200;
    var noArrow = 560;
    var stickOn = 600;

    if (distanceY > shrinkOn) {
      $('#logo').addClass("small");
      $('.nav').addClass("sticky");
    } else {
      $('#logo').removeClass("small");
      $('.nav').removeClass("sticky");
    };

    if (distanceY > noArrow) {
      $('.triangle').addClass("hidden");
      $('.section-arrow').addClass("sticky");
    } else {
      $('.triangle').removeClass("hidden");
      $('.section-arrow').removeClass("sticky");
    };

    if (distanceY > stickOn) {
      $('.banner').addClass("sticky");
      $('body').addClass("sticky");
      $('.button').addClass("sticky");
    } else {
      $('.banner').removeClass("sticky");
      $('body').removeClass("sticky");
      $('.button').removeClass("sticky");
    };
  });
}

window.onload = init();