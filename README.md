# FlibustaApp

Данное приложение позволит вам находить по названию и скачивать книги с сайта "flibusta.is".  
Если данный сайт заблокирован в вашей стране, приложение может найти бесплатный прокси сервер, через который вы сможете получить доступ к сайту.
Программа находится в стадии бета-тестирования.  
Для просмотра этого файла в удобной форме в VS Code, нажмите сочетание клавиш `Ctrl + Shift + V`.  

## Для запуска приложения в Windows необходимо:

1. Скачать c сайта [Flutter. Windows install](https://flutter.dev/docs/get-started/install/windows) архив с Flutter SDK
2. Разархивировать папку `flutter`, куда удобнее. Чтобы не было проблем, можно в `C:/flutter`
3. Запустить из папки `flutter_console.bat`
4. Добавить в environment variables в переменную `PATH` путь к вашему `flutter\bin`, например `C:\flutter\bin`
После этого перезагрузить камплюктер.
5. Установить [Android Studio](`https://developer.android.com/studio`).
6. Установить в VS Code и в Android Studio плагины Dart и Flutter
7. Открыть проект в Android Studio  
8. Установить пакеты, указанные в `pubspec.yaml`, с помощью команды `flutter pub get`  
9. Ввести в коммандной строке `flutter doctor` и решить указанные проблемы, если они есть. Принять лицензии Android `flutter doctor --android-licenses`  
10. Попробовать запустить приложение на подключенном устройстве или эмуляторе `F5`.  

### Комманды сборки APK

Prod: `flutter build apk`  

### Команды сборки AppBundle

Bundle: `flutter build appbundle --release`  


## Версия приложения

Версия приложения меняется в файле `pubspec.yaml`.  
Версия состоит из двух частей. Пример: `0.2.4+55`, где `0.2.4` это название версии, а `55` это номер версии.  
При билде Flutter автоматически обновляет версии в файлах определённой платформы.  
Для Android в файле `android/local.properties`.  
Для iOS в файле `ios/Runner/Info.plist`, вроде бы.  


## Рекомендации

1. Используйте тему для VSCode [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme)
2. Используйте расширение для VSCode [bloc](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) для создания новых BLoC
3. Желательно всегда форматировать файл перед сохранением комбинацией клавиш `Alt + Shift + F`  
