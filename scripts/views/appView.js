(function() {
  define(['jquery', 'underscore', 'backbone', 'collections/songs', 'views/songView'], function($, _, Backbone, SongsCollection, ItemView) {
    var AppView;
    AppView = Backbone.View.extend({
      el: '#mainBlock',
      events: {
        'click #addBut': 'addSong',
        'click #delAllBut': 'clearList',
        'click #filterBut': 'routeFilter',
        'click #resetBut': 'routeReset',
        'click .close': 'closeAlert'
      },
      initialize: function() {
        this.$addInput = this.$('#addBut');
        this.$inputSong = this.$('#songTitle');
        this.$inputAuthor = this.$('#songAuthor');
        this.$inputGenre = this.$('#songGenre');
        this.$content = this.$('.listContentBlock tbody');
        this.listenTo(SongsCollection, 'add', this.addOne);
        this.listenTo(SongsCollection, 'reset', this.addAll);
        this.listenTo(SongsCollection, 'filter', this.filterList);
        this.listenTo(SongsCollection, 'filterReset', this.filterReset);
        return SongsCollection.fetch({
          reset: true
        });
      },
      addOne: function(song) {
        var view;
        view = new ItemView({
          model: song
        });
        return this.$content.append(view.render().el);
      },
      resetAll: function(song) {
        if (song.get('filtered')) {
          return song.toggle();
        }
      },
      addAll: function() {
        this.$content.html('');
        SongsCollection.each(this.resetAll, this);
        return SongsCollection.each(this.addOne, this);
      },
      newAttributes: function() {
        return {
          title: this.$inputSong.val(),
          author: this.$inputAuthor.val(),
          genre: this.$inputGenre.val()
        };
      },
      addSong: function() {
        if (!this.$inputSong.val() || !this.$inputAuthor.val() || !this.$inputGenre.val()) {
          return this.alert('add');
        } else {
          SongsCollection.create(this.newAttributes());
          this.$inputSong.val('');
          this.$inputAuthor.val('');
          this.$inputGenre.val('');
          return Backbone.history.loadUrl(Backbone.history.getFragment());
        }
      },
      clearList: function() {
        _.invoke(SongsCollection.toArray(), 'destroy');
        return this.routeReset();
      },
      filterList: function() {
        this.alert('alert');
        return SongsCollection.each(function(song) {
          return song.trigger('checkCurItem');
        });
      },
      filterReset: function() {
        return SongsCollection.each(function(song) {
          if (song.get('filtered')) {
            return song.trigger('toggleFiltered');
          } else {
            return song.trigger('visibleOn');
          }
        }, $('#titleFilter').val(''), $('#authorFilter').val(''), $('#genreFilter').val(''), this.closeAlert(true));
      },
      alert: function(switcher) {
        this.$alertWarn = $('#alertWarn');
        switch (switcher) {
          case 'add':
            if (this.$alertWarn.hasClass('in')) {
              this.closeAlert(false);
            }
            this.$alertWarn.addClass('in').show();
            this.$alertWarn.css('top', '4px');
            this.$alertWarn.css('left', '318px');
            this.$alertWarn.css('width', '260px');
            return $('.WarningMes').text('Not all fields are filled');
          case 'filter':
            if (this.$alertWarn.hasClass('in')) {
              this.closeAlert(false);
            }
            this.$alertWarn.addClass('in').show();
            this.$alertWarn.css('top', '63px');
            this.$alertWarn.css('left', '348px');
            this.$alertWarn.css('width', '230px');
            return $('.WarningMes').text('No search terms');
          case 'alert':
            if (!$('#alertFilter').hasClass('in')) {
              return $('#alertFilter').addClass('in').show;
            }
        }
      },
      closeAlert: function(closer) {
        this.$alertWarn = $('#alertWarn');
        this.$alertWarn.removeClass('in').show();
        this.$alertWarn.css('display', 'none');
        if (closer) {
          if ($('#alertFilter').hasClass('in')) {
            return $('#alertFilter').removeClass('in').show();
          }
        }
      },
      routeFilter: function() {
        var filterStr;
        this.$filTitle = $('#titleFilter').val();
        this.$filAuthor = $('#authorFilter').val();
        this.$filGenre = $('#genreFilter').val();
        if (!this.$filTitle && !this.$filAuthor && !this.$filGenre) {
          this.alert('filter');
          return false;
        }
        this.alert('alert');
        filterStr = 'search?';
        if (this.$filTitle) {
          filterStr += '/title=' + this.$filTitle;
        }
        if (this.$filAuthor) {
          filterStr += '/author=' + this.$filAuthor;
        }
        if (this.$filGenre) {
          filterStr += '/genre=' + this.$filGenre;
        }
        return Backbone.history.navigate(filterStr, true);
      },
      routeReset: function() {
        return Backbone.history.navigate('', true);
      }
    });
    return AppView;
  });

}).call(this);
