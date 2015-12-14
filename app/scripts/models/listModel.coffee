define(
  ['underscore', 'backbone']
  (_, Backbone) ->
    SongModel = Backbone.Model.extend(
      defaults:
        title: ''
        author: ''
        genre: ''
        filtered: false
      toggle: ->
        this.save(filtered: !this.get('filtered'))
    )
    return SongModel
)
