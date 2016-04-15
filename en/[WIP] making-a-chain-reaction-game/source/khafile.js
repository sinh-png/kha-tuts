var project = new Project('Our Chain Reaction Game');

project.addAssets('Assets/**');
project.addSources('Sources');

// We set the game screen size when target Flash and HTML5.
project.windowOptions.width = 800;
project.windowOptions.height = 600;

return project;
