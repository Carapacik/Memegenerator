

class SaveTemplateInteractor {
  static const templatesPathName = "templates";
  static SaveTemplateInteractor? _instance;

  factory SaveTemplateInteractor.getInstance() =>
      _instance ??= SaveTemplateInteractor._internal();

  SaveTemplateInteractor._internal();
}
