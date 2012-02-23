$(document).ready(function() {
  $("div.postlet-image > img").load(function() {
    if (this.width == 1 || this.height == 1) {
      $(this).parent().hide();  
    }
  });
  
  $("embed").each(function(){
    $('embed').each(function(){
      sizeRatio = $(this).attr('width') / $(this).attr('height');
      newWidth = $(this).parent().width();
      newHeight = Math.round(newWidth / sizeRatio);
      $(this).attr('width', newWidth).attr('height', newHeight).parent().attr('width', newWidth).attr('height', newHeight);
      });
  });
});