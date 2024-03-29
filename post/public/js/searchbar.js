// Generated by CoffeeScript 1.6.3
(function() {
  $(document).ready(function() {
    var entFullW, entSmallW, iconW, margin, searchW;
    searchW = 340;
    iconW = 44;
    entFullW = 376;
    entSmallW = 69;
    margin = 17;
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
    return $('#ent_focus').mouseenter(function() {
      return $('#ent_focus .hidewrapper').stop().animate({
        width: entFullW,
        "margin-right": 0
      });
    }).mouseleave(function() {
      return $('#ent_focus .hidewrapper').stop().animate({
        width: entSmallW,
        "margin-right": margin
      });
    });
  });

}).call(this);
