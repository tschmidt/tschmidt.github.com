/* Author: Terry Schmidt

*/

(function ($) {
  
  $('a[href^=http]').click(openInNewWindow);
  
  function openInNewWindow() {
    var newWindow = window.open(this.getAttribute('href'), '_blank');
    newWindow.focus();
    return false;
  }
  
})(jQuery);