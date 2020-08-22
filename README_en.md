# Flibusta Browser

<img src="https://user-images.githubusercontent.com/8808766/89461752-16176980-d775-11ea-8920-2aec94c1524c.png" width ="128"/>

#### Language: [English](README_en.md) | [Русский](README.md)

![GitHub repo release](https://img.shields.io/github/v/release/utopicnarwhal/flibusta-mobile)

<a href='https://play.google.com/store/apps/details?id=ru.utopicnarwhal.flibustabrowser&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' height="78px" src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'/></a>

Flibusta Browser is an unofficial mobile application for site [`flibusta.is`](https://flibusta.is) that allows user to download eBooks from the site library.

## Features

* Authorization on the site for access to foreign literature.
* Add books to favorites or for later.
* List of recently opened books.
* Simple search for books, genres, series and authors.
* List of downloaded books.
* Advanced search for books by title, author's full name and genre.
* View book covers and annotations.
* Checking site availability.
* Two built-in proxy servers (do not work with Yota, will stop working on 09/21/2020).
* Use your own HTTP proxy or add from the site `pubproxy.com`.
* Integrated `Tor Onion Proxy`.
* Preferred book format for download.
* Light theme, Dark theme and follow the system theme option.
* Nice and clear design.

## Screenshots

<img src="https://user-images.githubusercontent.com/8808766/89352805-b8741600-d6bd-11ea-8267-17a19bb52156.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352816-bb6f0680-d6bd-11ea-89e5-7da313650763.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352804-b8741600-d6bd-11ea-8bd4-2978a53163e4.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352806-b90cac80-d6bd-11ea-93c1-23f7e6cfa57a.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352815-bad67000-d6bd-11ea-8381-dc0846cf7161.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352810-b9a54300-d6bd-11ea-9b3f-9f893b3d6179.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352817-bb6f0680-d6bd-11ea-96b6-22b1baac0def.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352813-ba3dd980-d6bd-11ea-99ab-0ff08f44053a.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352811-b9a54300-d6bd-11ea-8af4-3346654bcb3f.jpg" width ="200"/><img src="https://user-images.githubusercontent.com/8808766/89352803-b742e900-d6bd-11ea-8e75-58015540f304.jpg" width ="200"/>

## Building and Installing `Flibusta Browser` locally

This application was created using [Flutter SDK](https://flutter.dev).  
This application can be compiled for iOS (Tor Onion Proxy will not work), and there may be problems with saving books (not tested).

**Generating JSON Model Serialization**: `flutter packages pub run build_runner watch --delete-conflicting-outputs`

**Install on connected device**: `flutter run --release`  
**APK**: `flutter build apk --no-shrink` or `flutter build apk --split-per-abi --no-shrink`  
**Bundle**: `flutter build appbundle --no-shrink`  

## Contributing to `Flibusta Browser`

To contribute to this application, follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).

## Contributors

There is no contributors yet.

## Contact

If you want to contact me you can reach me at <gigok@bk.ru>.

## License

This project uses the following license: [Apache License 2.0](<LICENSE>).
