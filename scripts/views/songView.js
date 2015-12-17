(function() {
  define(['jquery', 'underscore', 'backbone', 'text!templates/song.html', 'collections/songs', 'common'], function($, _, Backbone, songTemplate, SongsCollection, Common) {
    var ItemView;
    ItemView = Backbone.View.extend({
      tagName: 'tr',
      template: _.template(songTemplate),
      events: {
        'dblclick .view': 'edit',
        'keypress .editing .edit': 'updateOnEnter',
        'keydown .editing .edit': 'revertOnEscape',
        'blur .editing .edit': 'close',
        'click .destroy': 'clear',
        'click .view': 'routeItem'
      },
      initialize: function() {
        this.listenTo(this.model, 'change', this.render);
        this.listenTo(this.model, 'destroy', this.remove);
        this.listenTo(this.model, 'visibleOn', this.visibleOn);
        this.listenTo(this.model, 'toggleFiltered', this.toggleFiltered);
        return this.listenTo(this.model, 'checkCurItem', this.checkItem);
      },
      render: function() {
        this.$el.html(this.template(this.model.toJSON()));
        this.$td = this.$('.edit').parent();
        return this;
      },
      visibleOn: function() {
        return this.$el.toggleClass('filtered', false);
      },
      visibleOff: function() {
        return this.$el.toggleClass('filtered', true);
      },
      clear: function() {
        this.model.destroy();
        return Backbone.history.loadUrl(Backbone.history.getFragment());
      },
      toggleFiltered: function() {
        return this.model.toggle();
      },
      checkItem: function(title, author, genre) {
        var authorCheck, genreCheck, titleCheck;
        titleCheck = this.checkAndTest($('#titleFilter').val(), this.model.get('title'));
        authorCheck = this.checkAndTest($('#authorFilter').val(), this.model.get('author'));
        genreCheck = this.checkAndTest($('#genreFilter').val(), this.model.get('genre'));
        if (titleCheck && authorCheck && genreCheck) {
          this.toggleFiltered();
          if (this.$el.hasClass('filtered')) {
            return this.visibleOn();
          }
        } else {
          if (this.model.get('filtered')) {
            this.toggleFiltered();
          }
          return this.visibleOff();
        }
      },
      checkAndTest: function(inputVal, listVal) {
        var tester;
        if (inputVal) {
          inputVal = inputVal.toLowerCase();
          listVal = listVal.toLowerCase();
          tester = listVal.indexOf(inputVal) + 1;
          if (!tester) {
            return false;
          }
        }
        return true;
      },
      edit: function(e) {
        this.$myTd = $(e.currentTarget);
        this.$myInput = $(e.currentTarget).children('.edit');
        this.$myValue = $(e.currentTarget).children('div');
        this.$myInput.val(this.$myValue.text());
        $(e.currentTarget).addClass('editing');
        return this.$myInput.focus();
      },
      updateOnEnter: function(e) {
        if (e.which === Common.ENTER_KEY) {
          return this.close();
        }
      },
      revertOnEscape: function(e) {
        if (e.which === Common.ESC_KEY) {
          return this.$myTd.removeClass('editing');
        }
      },
      close: function() {
        var attrId, value;
        value = this.$myInput.val();
        attrId = this.$myInput.data('id');
        if (value && value !== this.model.get(attrId)) {
          this.model.save(attrId, value);
          Backbone.history.loadUrl(Backbone.history.getFragment());
        }
        return this.$myTd.removeClass('editing');
      },
      routeItem: function() {
        var id, songMass;
        songMass = SongsCollection.toArray();
        id = 0;
        console.log(songMass);
        console.log(this.model.cid);
        while (songMass[id].cid !== this.model.cid) {
          id++;
        }
        id++;
        return Backbone.history.navigate('items/' + id, true);
      }
    });
    return ItemView;
  });

}).call(this);
