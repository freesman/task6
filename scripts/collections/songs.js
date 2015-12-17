(function() {
  define(['underscore', 'backbone', 'backboneLocalstorage', 'models/listModel'], function(_, Backbone, Store, SongModel) {
    var SongsCollection;
    SongsCollection = Backbone.Collection.extend({
      model: SongModel,
      localStorage: new Store('songList-storage'),
      nextOrder: function() {
        if (this.length) {
          return this.last().get('order') + 1;
        } else {
          return 1;
        }
      },
      comparator: function() {
        return 'order';
      },
      filtered: function() {
        return this.where({
          filtered: true
        });
      }
    });
    return new SongsCollection();
  });

}).call(this);
