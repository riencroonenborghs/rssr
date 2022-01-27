$(function() {
  $(".navbar .navbar-brand .navbar-burger").on("click", function(e) {
    $(".navbar .navbar-brand .navbar-burger").toggleClass("is-active");
    $(".navbar .navbar-menu").toggleClass("is-active");
  });
});
