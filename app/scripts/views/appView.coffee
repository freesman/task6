define(
  ['jquery', 'underscore', 'backbone', 'collections/songs', 'views/songView']
  ($, _, Backbone, SongsCollection, ItemView) ->
    AppView = Backbone.View.extend(
      el: '#mainBlock',
      events:
        'click #addBut': 'addSong'
        'click #delAllBut': 'clearList'
        'click #filterBut': 'routeFilter'
        'click #resetBut': 'routeReset'
        'click .close': 'closeAlert'
      initialize: ->
        this.$addInput = this.$('#addBut')
        this.$inputSong = this.$('#songTitle')
        this.$inputAuthor = this.$('#songAuthor')
        this.$inputGenre = this.$('#songGenre')
        this.$content = this.$('.listContentBlock tbody')

        this.listenTo(SongsCollection, 'add', this.addOne)
        this.listenTo(SongsCollection, 'reset', this.addAll)
        this.listenTo(SongsCollection, 'filter', this.filterList)
        this.listenTo(SongsCollection, 'filterReset', this.filterReset)
        SongsCollection.fetch(reset: true)
      addOne: (song) ->
        view = new ItemView(model: song)
        this.$content.append(view.render().el)
      resetAll: (song) ->
        if song.get('filtered')
          song.toggle()
      addAll: ->
        this.$content.html('')
        SongsCollection.each(this.resetAll, this)
        SongsCollection.each(this.addOne, this)
      newAttributes: ->
        return {} =
          title: this.$inputSong.val()
          author: this.$inputAuthor.val()
          genre: this.$inputGenre.val()
      addSong: ->
        if !this.$inputSong.val() or !this.$inputAuthor.val() or !this.$inputGenre.val()
          this.alert('add')
        else
          SongsCollection.create(this.newAttributes())
          this.$inputSong.val('')
          this.$inputAuthor.val('')
          this.$inputGenre.val('')
          Backbone.history.loadUrl(Backbone.history.getFragment())
      clearList: ->
        _.invoke(SongsCollection.toArray(), 'destroy')
        this.routeReset()
      filterList: ->
        this.alert('alert')
        SongsCollection.each((song)->
          song.trigger('checkCurItem')
        )
      filterReset: ->
        SongsCollection.each((song)->
          if song.get('filtered')
            song.trigger('toggleFiltered')
          else
            song.trigger('visibleOn')
        $('#titleFilter').val('')
        $('#authorFilter').val('')
        $('#genreFilter').val('')
        this.closeAlert(true)
        )
      alert: (switcher)-> # show <!> when filter list
        this.$alertWarn = $('#alertWarn')
        switch switcher
          when 'add'
            if this.$alertWarn.hasClass('in')
              this.closeAlert(false)
            this.$alertWarn.addClass('in').show()
            this.$alertWarn.css('top', '4px')
            this.$alertWarn.css('left', '318px')
            this.$alertWarn.css('width', '260px')
            $('.WarningMes').text('Not all fields are filled')
          when 'filter'
            if this.$alertWarn.hasClass('in')
              this.closeAlert(false)
            this.$alertWarn.addClass('in').show()
            this.$alertWarn.css('top', '63px')
            this.$alertWarn.css('left', '348px')
            this.$alertWarn.css('width', '230px')
            $('.WarningMes').text('No search terms')
          when 'alert'
            if !$('#alertFilter').hasClass('in')
            then $('#alertFilter').addClass('in').show
      closeAlert: (closer) ->
        this.$alertWarn = $('#alertWarn')
        this.$alertWarn.removeClass('in').show()
        this.$alertWarn.css('display', 'none')
        if closer
          if $('#alertFilter').hasClass('in')
          then $('#alertFilter').removeClass('in').show()
      routeFilter: -> # route on click filter button
        this.$filTitle = $('#titleFilter').val()
        this.$filAuthor = $('#authorFilter').val()
        this.$filGenre = $('#genreFilter').val()
        if !this.$filTitle and !this.$filAuthor and !this.$filGenre
          this.alert('filter')
          return false
        this.alert('alert')
        filterStr = 'search?'
        if this.$filTitle
          filterStr += '/title=' + this.$filTitle
        if this.$filAuthor
          filterStr += '/author=' + this.$filAuthor
        if this.$filGenre
          filterStr += '/genre=' + this.$filGenre
        Backbone.history.navigate(filterStr, true)
      routeReset: ->
        Backbone.history.navigate('', true)
    )
    return AppView
)
