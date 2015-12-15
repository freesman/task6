define(
  ['jquery', 'underscore', 'backbone', 'text!templates/song.html', 'collections/songs', 'common']
  ($, _, Backbone, songTemplate, SongsCollection, Common) ->
    ItemView = Backbone.View.extend(
      tagName: 'tr'
      template: _.template(songTemplate)
      events:
        'dblclick .view': 'edit'
        'keypress .editing .edit': 'updateOnEnter'
        'keydown .editing .edit': 'revertOnEscape'
        'blur .editing .edit': 'close'
        'click .destroy': 'clear'
        'click .view': 'routeItem'
      initialize: ->
        this.listenTo(this.model, 'change', this.render)
        this.listenTo(this.model, 'destroy', this.remove)
        this.listenTo(this.model, 'visibleOn', this.visibleOn) # show filtered elements
        this.listenTo(this.model, 'toggleFiltered', this.toggleFiltered) # toggle 'filtered' attribute
        this.listenTo(this.model, 'checkCurItem', this.checkItem) # check every element = filtered?
      render: ->
        this.$el.html(this.template(this.model.toJSON()))
        this.$td = this.$('.edit').parent()
        return this
      visibleOn: ->
        this.$el.toggleClass('filtered', false)
      visibleOff: ->
        this.$el.toggleClass('filtered', true)
      clear: ->
        this.model.destroy()
        Backbone.history.loadUrl(Backbone.history.getFragment())
      toggleFiltered: ->
        this.model.toggle()
      checkItem: (title, author, genre) ->
        titleCheck = this.checkAndTest($('#titleFilter').val(), this.model.get('title'))
        authorCheck = this.checkAndTest($('#authorFilter').val(), this.model.get('author'))
        genreCheck = this.checkAndTest($('#genreFilter').val(), this.model.get('genre'))
        if titleCheck and authorCheck and genreCheck
          this.toggleFiltered()
          if this.$el.hasClass('filtered')
            this.visibleOn()
        else
          if this.model.get('filtered')
            this.toggleFiltered()
          this.visibleOff()
      checkAndTest: (inputVal, listVal) ->
        if inputVal
          inputVal = inputVal.toLowerCase()
          listVal = listVal.toLowerCase()
          tester = listVal.indexOf(inputVal) + 1
          if !tester
            return false
        return true
      edit: (e)->
        this.$myTd = $(e.currentTarget)
        this.$myInput = $(e.currentTarget).children('.edit')
        this.$myValue = $(e.currentTarget).children('div')
        this.$myInput.val(this.$myValue.text())
        $(e.currentTarget).addClass('editing')
        this.$myInput.focus()
      updateOnEnter: (e)->
        if e.which == Common.ENTER_KEY
          this.close()
      revertOnEscape: (e)->
        if e.which == Common.ESC_KEY
          this.$myTd.removeClass('editing')
      close: ->
        value = this.$myInput.val()
        attrId = this.$myInput.data('id')
        if value and value != this.model.get(attrId)
          this.model.save(attrId, value)
          Backbone.history.loadUrl(Backbone.history.getFragment()) # refresh route cur item after editing
        this.$myTd.removeClass('editing')
      routeItem: -> # route to item on click some attribute in list
        songMass = SongsCollection.toArray()
        id = 0
        while songMass[id].cid != this.model.cid
          id++
        id++
        Backbone.history.navigate('items/' + id, true)
        Backbone.history.loadUrl(Backbone.history.getFragment())
    )
    return ItemView
)
