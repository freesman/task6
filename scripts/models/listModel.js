(function() {
  define(['underscore', 'backbone'], function(_, Backbone) {
    var SongModel;
    SongModel = Backbone.Model.extend({
      defaults: {
        title: '',
        author: '',
        genre: '',
        filtered: false
      },
      toggle: function() {
        return this.save({
          filtered: !this.get('filtered')
        });
      }
    });
    return SongModel;
  });

}).call(this);
