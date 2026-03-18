# ImageFeed

## Описание

ImageFeed — это многостраничное iOS-приложение для просмотра фотографий из сервиса Unsplash.

Приложение позволяет пользователю просматривать бесконечную ленту изображений, открывать изображения в полноэкранном режиме, ставить лайки и управлять избранным, а также просматривать информацию о своем профиле.

Проект разработан в учебных целях для практики работы с:
- сетевыми запросами и REST API
- авторизацией через OAuth 2.0
- вертской многостраничного приложения с навигацией и таб баром
- обработкой асинхронных данных и состояний загрузки

## Стек

- Swift
- UIKit
- Арихтектура MVP
- URLSession
- OAuth 2.0
- UITableView
- UINavigationController / UITabBarController
- Auto Layout

## Требования

- Xcode 11+
- iOS 13+
- Swift 5+

## Установка

1. Клонировать репозиторий: `git clone https://github.com/BeerHobbit/ImageFeed.git`
3. Открыть проект в Xcode
4. Добавить свои API-ключи Unsplash:
    - Создать приложение на [Unsplash Developers](https://unsplash.com/developers)
    - Скопировать Access Key, Secret Key и Redirect URI
    - Заменить ключи и URI в файле Namespaces.swift по пути: ImageFeed/Helpers/Namespaces.swift
5. Запустить проект на эмуляторе или подключенном устройстве


