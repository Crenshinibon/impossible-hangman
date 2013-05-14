Package.describe({
    summary: 'Filesystem access on the server'
});

Package.on_use(function (api) {
  api.use('coffeescript','server');
  api.add_files('fs.coffee','server');
});