var project = new Project('Ball Avoider');

project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addSources('Sources');

// We set the screen size when target Flash and HTML5.
project.windowOptions.width = 800;
project.windowOptions.height = 600;

return project;
