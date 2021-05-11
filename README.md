# Флибуста Browser

<img src="https://user-images.githubusercontent.com/8808766/89461752-16176980-d775-11ea-8920-2aec94c1524c.png" width ="128"/>

#### Language: [English](README_en.md) | [Русский](README.md)

![GitHub repo release](https://img.shields.io/github/v/release/utopicnarwhal/flibusta-mobile)
[![Codemagic build status](https://api.codemagic.io/apps/5f7894bc21e1c04a4ec9c0a3/5f79eb7121e1c0372b34b27c/status_badge.svg)](https://codemagic.io/apps/5f7894bc21e1c04a4ec9c0a3/5f79eb7121e1c0372b34b27c/latest_build)

<a href='https://play.google.com/store/apps/details?id=ru.utopicnarwhal.flibustabrowser&hl=ru&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Доступно в Google Play' height="78px" src='https://play.google.com/intl/en_us/badges/images/generic/ru_badge_web_generic.png'/></a>

## О приложении

Флибуста Browser это неофициальное приложение для сайта [`flibusta.is`](https://flibusta.is).  
Позволяет находить и скачивать книги из библиотеки Флибусты.  

### Особенности

* Авторизация на сайте для доступа к иностранной литературе.
* Возможность добавления книг в избранное или на потом.
* Список последних открытых книг.
* Простой поиск книг, жанров, сериалов и авторов.
* Список скачанных книг.
* Расширенный поиск книг по названию, ФИО автора и жанру.
* Просмотр обложки и аннотации книги.
* Проверка доступности сайта.
* Два встроенных прокси-сервера создателя приложения (не работают у Yota, перестанут работать 21.09.2020).
* Возможность использовать свой HTTP прокси или добавить с сайта `pubproxy.com`.
* Интегрированный `Tor Onion Proxy`.
* Выбор предпочитаемого формата книги для скачивания.
* Светлая тема, Тёмная тема, следование теме системы.
* Приятный и понятный дизайн.

## Скриншоты

<img src="https://user-images.githubusercontent.com/8808766/89352805-b8741600-d6bd-11ea-8267-17a19bb52156.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352816-bb6f0680-d6bd-11ea-89e5-7da313650763.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352804-b8741600-d6bd-11ea-8bd4-2978a53163e4.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352806-b90cac80-d6bd-11ea-93c1-23f7e6cfa57a.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352815-bad67000-d6bd-11ea-8381-dc0846cf7161.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352810-b9a54300-d6bd-11ea-9b3f-9f893b3d6179.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352817-bb6f0680-d6bd-11ea-96b6-22b1baac0def.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352813-ba3dd980-d6bd-11ea-99ab-0ff08f44053a.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352811-b9a54300-d6bd-11ea-8af4-3346654bcb3f.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352803-b742e900-d6bd-11ea-8e75-58015540f304.jpg" width ="200"/>

## Разработка

Данное приложение создано с помощью технологии [Flutter](https://flutter.dev). Рекомендую ознакомиться с данным SDK.  
Это приложение можно собрать и под iOS, только не будет работать Tor Onion Proxy, а также могут быть проблемы с сохранением книг (не тестировал).

### Генерация сериализации моделей

`flutter packages pub run build_runner watch --delete-conflicting-outputs`

### Комманды сборки

**APK**: `flutter build apk --no-shrink` или `flutter build apk --split-per-abi --no-shrink`  
**Bundle**: `flutter build appbundle --no-shrink`  

## Как помочь кодом?

Создайте Pull Request.

## Связь

Если хотите связаться со мной, то напишите на почту <gigok@bk.ru>.

## Лицензия

Данный проект распространяется под лицензией: [Apache License 2.0](<LICENSE>).
