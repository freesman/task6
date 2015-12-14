
ENTER_KEY = 13
ESC_KEY = 27

# model -------------
SongModel = Backbone.Model.extend(
  defaults:
    title: ''
    author: ''
    genre: ''
    filtered: false
  toggle: ->
    this.save(filtered: !this.get('filtered'))
)

# collection [v-v-v-v-v-v] -------------
SongsCollection = Backbone.Collection.extend(
  model: SongModel
  localStorage: new Backbone.LocalStorage('songList-storage')
  nextOrder: -> #create uniq id for each model in list
    if this.length
    then this.last().get('order') + 1
    else 1
  comparator: -> 'order'
  filtered: ->
    return this.where(filtered: true)
)

songList = new SongsCollection

#list items view [v] -------------
ItemView = Backbone.View.extend(
  tagName: 'tr'
  template: _.template($('#item-template').html())
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
    if e.which == ENTER_KEY
      this.close()
  revertOnEscape: (e)->
    if e.which == ESC_KEY
      this.$myTd.removeClass('editing')
  close: ->
    value = this.$myInput.val()
    attrId = this.$myInput.data('id')
    if value and value != this.model.get(attrId)
      this.model.save(attrId, value)
      Backbone.history.loadUrl(Backbone.history.getFragment()) # refresh route cur item after editing
    this.$myTd.removeClass('editing')
  routeItem: -> # route to item on click some attribute in list
    songMass = songList.toArray()
    id = 0
    while songMass[id].cid != this.model.cid
      id++
    id++
    webListRouter.navigate('items/' + id, true)
)

#application view __________________________/\
#                                           \/
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

    this.listenTo(songList, 'add', this.addOne)
    this.listenTo(songList, 'reset', this.addAll)
    this.listenTo(songList, 'filter', this.filterList)
    this.listenTo(songList, 'filterReset', this.filterReset)
    songList.fetch(reset: true)
  addOne: (song) ->
    view = new ItemView(model: song)
    this.$content.append(view.render().el)
  resetAll: (song) ->
    if song.get('filtered')
      song.toggle()
  addAll: ->
    this.$content.html('')
    songList.each(this.resetAll, this)
    songList.each(this.addOne, this)
  newAttributes: ->
    return {} =
      title: this.$inputSong.val()
      author: this.$inputAuthor.val()
      genre: this.$inputGenre.val()
  addSong: ->
    if !this.$inputSong.val() or !this.$inputAuthor.val() or !this.$inputGenre.val()
      this.alert('add')
    else
      songList.create(this.newAttributes())
      this.$inputSong.val('')
      this.$inputAuthor.val('')
      this.$inputGenre.val('')
  clearList: ->
    _.invoke(songList.toArray(), 'destroy')
  filterList: ->
    this.alert('alert')
    songList.each((song)->
      song.trigger('checkCurItem')
    )
  filterReset: ->
    songList.each((song)->
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
    webListRouter.navigate(filterStr, true)
  routeReset: ->
    webListRouter.navigate('', true)
)

app = new AppView

#router ---------->->->->------------>->->->
Router = Backbone.Router.extend(
  routes:
    ''            :'index' # start page route
    'items/:id'   :'items' # route cur element
    'search?(/title=:strT)(/author=:strA)(/genre=:strG)' :'search' # filter route
    'search?*error'    :'searchError' # wrong search route
    '*other'      :'default' # other wrong routes
  index: ->
    this.routeIndex(true)
    $('.routeMessage p').text('choose your elemet: \'../#/items/?\'')
    songList.trigger('filterReset')
  items: (id) ->
    if id < 1 or id > songList.length
      this.routeError(id)
      return false
    this.routeIndex(false)
    songMass = songList.toArray()
    idMass = id - 1
    title = 'title: ' + songMass[idMass].attributes.title
    author = 'author: ' + songMass[idMass].attributes.author
    genre = 'genre: ' + songMass[idMass].attributes.genre
    $('.num p').text('# ' + id + '/' + songList.length)
    $('#routeTitle').text(title)
    $('#routeAuthor').text(author)
    $('#routeGenre').text(genre)
  search: (strT, strA, strG) ->
    $('#titleFilter').val(strT)
    $('#authorFilter').val(strA)
    $('#genreFilter').val(strG)
    songList.trigger('filter')
  default: (other) ->
    this.routeIndex(true)
    $('.routeMessage p').text('route \'' + other  + '\' does not exist')
  searchError: (error) ->
    this.routeIndex(true)
    $('.routeMessage p').text('search error: route \'' + error  + '\' does not exist')
  routeError: (id) ->
    this.routeIndex(true)
    $('.routeMessage p').text('song with number: \'' + id  + '\' does not exist')
  routeIndex: (switchIndex) ->
    if switchIndex
      $('.routeMessage').css('display', 'block')
      $('.routeElement').css('display', 'none')
    else
      $('.routeMessage').css('display', 'none')
      $('.routeElement').css('display', 'block')
)

webListRouter = new Router()
Backbone.history.start()
