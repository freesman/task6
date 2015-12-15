require.config({
  shim:{
    underscore: {
      exports:'_'
    },
    backbone:{
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    },
    backboneLocalstorage: {
        deps: ['backbone'],
        exports: 'Store'
    }
  },
  paths: {
    jquery: '../../bower_components/jquery/dist/jquery',
    underscore: '../../bower_components/underscore/underscore',
    backbone: '../../bower_components/backbone/backbone',
    backboneLocalstorage: '../../bower_components/backbone.localStorage/backbone.localStorage',
    text: '../../bower_components/text/text'
  }
});

require(
  ['backbone', 'views/appView', 'routers/listRouter'],
  function(Backbone, AppView, Workspace){
    new Workspace();
    Backbone.history.start();
    new AppView();
  }
);
