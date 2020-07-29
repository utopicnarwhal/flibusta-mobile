# Мобильное приложение Флибуста Browser (Android). ЗАВЕРШЕНО

<a href='https://play.google.com/store/apps/details?id=ru.utopicnarwhal.flibustabrowser&hl=ru&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Доступно в Google Play' width="30%" src='https://play.google.com/intl/en_us/badges/images/generic/ru_badge_web_generic.png'/></a>

Данное приложение позволит вам находить по названию и скачивать книги с сайта "flibusta.is" или его зеркал.  
Если данный сайт заблокирован в вашей стране, в приложении есть встроенные прокси создателя приложения, через которые вы сможете получить доступ к сайту. Также есть возможность включить Tor Onion Proxy.
Для просмотра этого файла в удобной форме в VS Code, нажмите сочетание клавиш `Ctrl + Shift + V`.  

## Генерация сериализации моделей

1. Запустите в терминале VS Сode `flutter packages pub run build_runner watch --delete-conflicting-outputs`

## Сборка
### Комманды сборки APK

Prod: `flutter build apk --no-shrink`  

### Команды сборки AppBundle

Bundle: `flutter build appbundle --no-shrink`  


## Проверка обновлений пакетов

`flutter pub outdated`

## Версия приложения

Версия приложения меняется в файле `pubspec.yaml`.  
Версия состоит из двух частей. Пример: `0.2.4+55`, где `0.2.4` это название версии, а `55` это номер версии(сборки).  
При билде Flutter автоматически обновляет версии в файлах определённой платформы.  
Для Android в файле `android/local.properties`.  
Для iOS в файле `ios/Runner/Info.plist`, вроде бы.  


## Рекомендации

1. Используйте тему иконок для VSCode [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme).
2. Используйте расширение для VSCode [bloc](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) для создания новых BLoC.
3. Используйте [Better Comments](https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments), для наглядности комментариев.
4. Зайдите в настройки расширения `Dart` и включите опцию `Dart: Preview Flutter Ui Guides`.
5. Желательно всегда форматировать файл перед сохранением комбинацией клавиш `Alt + Shift + F`. Если выглядит некрасиво, то можно пробывать добавлять/удалять запятые, чтобы красиво переносилось на следующую строчку.
6. Для редактирования этого файла используйте расширение [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one), будет легче работать со списками.
