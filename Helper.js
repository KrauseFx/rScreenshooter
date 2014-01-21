function captureLocalizedScreenshot(name) {
  var target = UIATarget.localTarget();
  var model = target.model();
  var rect = target.rect();

  if (model.match(/iPhone/)) 
  {
    if (rect.size.height > 480) model = "iOS-4-in";
    else model = "iOS-3.5-in";
  } 
  else 
  {
    model = "iOS-iPad";
  }

  var orientation = "portrait";
  if (rect.size.height < rect.size.width) orientation = "landscape";

  var language = target.frontMostApp().
    preferencesValueForKey("AppleLanguages")[0];

  var parts = [language, model, orientation, name];
  target.captureScreenWithName(parts.join("___"));
}