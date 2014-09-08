// Generated by CoffeeScript 1.6.3
(function() {
  $(document).ready(function() {
    var entFullW, entSmallW, iconW, searchW;
    searchW = 340;
    iconW = 44;
    entFullW = 208;
    entSmallW = 53;
    if ($('#searchbox').val() !== '') {
      $('#search').css('width', searchW);
    }
    $('#search').mouseenter(function() {
      return $(this).stop().animate({
        width: searchW
      });
    }).mouseleave(function() {
      if ($('#searchbox').val() === '' && !$('#searchbox').is(':focus')) {
        return $(this).stop().animate({
          width: iconW
        });
      }
    });
    $('#searchbox').blur(function() {
      if ($('#searchbox').val() === '' && !$('#search').is(':hover')) {
        return $('#search').stop().animate({
          width: iconW
        });
      }
    });
    return $('#entertainment a .hide').mouseenter(function() {
      return $(this).stop().animate({
        width: entFullW
      });
    }).mouseleave(function() {
      return $(this).stop().animate({
        width: entSmallW
      });
    });
  });

}).call(this);
