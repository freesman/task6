define(
  ['underscore', 'backbone', 'backboneLocalstorage', 'models/listModel']
  (_, Backbone, Store, SongModel) ->
    SongsCollection = Backbone.Collection.extend(
      model: SongModel
      localStorage: new Store('songList-storage')
      nextOrder: -> #create uniq id for each model in list
        if this.length
        then this.last().get('order') + 1
        else 1
      comparator: -> 'order'
      filtered: ->
        return this.where(filtered: true)
    )
    return new SongsCollection() #()?
)
