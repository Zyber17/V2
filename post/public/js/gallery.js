// Generated by CoffeeScript 1.6.3
(function() {
  var cleanse, item, nextPhoto, prevPhoto, totalitems;

  totalitems = 0;

  item = 0;

  $(document).ready(function() {
    totalitems = parseInt($('.galleryCount').val());
    $('#prevPhoto').click(function() {
      return prevPhoto();
    });
    return $('#nextPhoto').click(function() {
      return nextPhoto();
    });
  });

  cleanse = function() {
    return $("#gallery>ul>li").removeClass('selected');
  };

  prevPhoto = function() {
    cleanse();
    item = item !== 0 ? (item - 1) % totalitems : totalitems - 1;
    return $("#galleryLi" + item).addClass('selected');
  };

  nextPhoto = function() {
    cleanse();
    item = (item + 1) % totalitems;
    return $("#galleryLi" + item).addClass('selected');
  };

}).call(this);
