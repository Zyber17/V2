// Generated by CoffeeScript 1.6.3
(function() {
  $(document).ready(function() {
    var iconW, searchW;
    searchW = 332;
    iconW = 32;
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
    return $('#searchbox').blur(function() {
      if ($('#searchbox').val() === '' && !$('#search').is(':hover')) {
        return $('#search').stop().animate({
          width: iconW
        });
      }
    });
  });

}).call(this);
