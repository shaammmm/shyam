# SASit

A mindful social media app built with Flutter for sharing photo and video moments with friends.

## Features

- Browse a social feed, like posts, comment, tag people, and search posts by people, places, or captions.
- Create a post with a caption and tags, or share a post directly into a personal chat or group room.
- Read and send messages in personal chats and group rooms.
- Set a browsing timer. When it ends, choose to stop or see one last post before the feed closes for the day.
- Choose between Terracotta, Lavender, and Midnight themes.

This repository contains a front-end prototype. Account details, posts, and chats are held in memory and reset when the app restarts. Media previews load from public image URLs; real authentication, uploads, and video playback need a backend and media service.

## Run locally

Install the Flutter SDK, then from the repository root run:

```sh
flutter create .
flutter pub get
flutter run
```