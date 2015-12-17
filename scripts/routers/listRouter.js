(function() {
  define(['jquery', 'backbone', 'collections/songs'], function($, Backbone, SongsCollection) {
    var Router;
    Router = Backbone.Router.extend({
      routes: {
        '': 'index',
        'items/:id': 'items',
        'search?(/title=:strT)(/author=:strA)(/genre=:strG)': 'search',
        'search?*error': 'searchError',
        '*other': 'default'
      },
      index: function() {
        this.routeIndex(true);
        $('.routeMessage p').text('choose your elemet: \'../#/items/?\'');
        return SongsCollection.trigger('filterReset');
      },
      items: function(id) {
        var author, genre, idMass, songMass, title;
        if (id < 1 || id > SongsCollection.length) {
          this.routeError(id);
          return false;
        }
        this.routeIndex(false);
        songMass = SongsCollection.toArray();
        idMass = id - 1;
        title = 'title: ' + songMass[idMass].attributes.title;
        author = 'author: ' + songMass[idMass].attributes.author;
        genre = 'genre: ' + songMass[idMass].attributes.genre;
        $('.num p').text('# ' + id + '/' + SongsCollection.length);
        $('#routeTitle').text(title);
        $('#routeAuthor').text(author);
        return $('#routeGenre').text(genre);
      },
      search: function(strT, strA, strG) {
        $('#titleFilter').val(strT);
        $('#authorFilter').val(strA);
        $('#genreFilter').val(strG);
        return SongsCollection.trigger('filter');
      },
      "default": function(other) {
        this.routeIndex(true);
        return $('.routeMessage p').text('route \'' + other + '\' does not exist');
      },
      searchError: function(error) {
        this.routeIndex(true);
        return $('.routeMessage p').text('search error: route \'' + error + '\' does not exist');
      },
      routeError: function(id) {
        this.routeIndex(true);
        return $('.routeMessage p').text('song with number: \'' + id + '\' does not exist');
      },
      routeIndex: function(switchIndex) {
        if (switchIndex) {
          $('.routeMessage').css('display', 'block');
          return $('.routeElement').css('display', 'none');
        } else {
          $('.routeMessage').css('display', 'none');
          return $('.routeElement').css('display', 'block');
        }
      }
    });
    return Router;
  });

}).call(this);
