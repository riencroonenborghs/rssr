$(function() {
  $("#admin form #youtube-feed").on("click", function() {
    $("#admin form #feed_url").val("https://www.youtube.com/feeds/videos.xml?channel_id=<VIDEO_ID>");
  });
});
