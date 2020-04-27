// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require decidim/time_tracker/time_entry
//= require_self

$(function() {
  var $activities = $('.activity');
  var activities = {};

  $activities.each(function() {
    var id = $(this).data('activity-id');
    var button_start = $("button[id='start'][data-activity-id='" + id + "']");
    button_start.click(function() {
      var time_entry = activities[id];
      let elapsed_time;

      if (!time_entry) {
        time_entry = new TimeEntry();
        time_entry.start();
        activities[id] = time_entry;
      }  else if (!time_entry.interval) {
        time_entry.resume();
      }

      elapsed_time = time_entry.getElapsedTime;
      if (!time_entry.interval) {
        activities[id].interval = setInterval( function() {
          elapsed_time += 100;
          var seconds = Math.floor(elapsed_time/ (1000));
          var minutes = Math.floor(seconds/ (1000 * 60));
          var hour = Math.floor(minutes / 60);
          $("[data-id='elapsed_time_" + id +"'").html( hour % 60 + "h " + minutes % 60 + "m " + seconds % 60 + "s");
        }, 100);
      }
    });

    var button_pause = $("button[id='pause'][data-activity-id='" + id + "']");
    button_pause.click(function() {
      var time_entry = activities[id];
      time_entry.pause();
      clearInterval(time_entry.interval);
      time_entry.interval = 0;
    });

    var button_stop = $("button[id='stop'][data-activity-id='" + id + "']");
    button_stop.click(function() {
      var time_entry = activities[id];
      time_entry.stop();
      clearInterval(time_entry.interval);
      time_entry.interval = -1
    });
  });

});

