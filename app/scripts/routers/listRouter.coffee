define(
  ['jquery', 'backbone', 'collections/songs']
  ($, Backbone, SongsCollection) ->
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
        SongsCollection.trigger('filterReset')
      items: (id) ->
        #this.refresh(true)
        console.log(this)
        console.log(SongsCollection)
        if id < 1 or id > SongsCollection.length
          this.routeError(id)
          return false
        this.routeIndex(false)
        songMass = SongsCollection.toArray()
        idMass = id - 1
        title = 'title: ' + songMass[idMass].attributes.title
        author = 'author: ' + songMass[idMass].attributes.author
        genre = 'genre: ' + songMass[idMass].attributes.genre
        $('.num p').text('# ' + id + '/' + SongsCollection.length)
        $('#routeTitle').text(title)
        $('#routeAuthor').text(author)
        $('#routeGenre').text(genre)
      search: (strT, strA, strG) ->
        $('#titleFilter').val(strT)
        $('#authorFilter').val(strA)
        $('#genreFilter').val(strG)
        SongsCollection.trigger('filter')
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
    return Router
)
