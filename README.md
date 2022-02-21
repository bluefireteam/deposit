<h1 align="center">
deposit
</h1>

<p align="center">
A data backend agnostic repository pattern package for Dart and Flutter.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/deposit" ><img src="https://img.shields.io/pub/v/deposit.svg?style=popout" /></a>
  <img src="https://github.com/bluefireteam/deposit/workflows/cicd/badge.svg?branch=main&event=push" alt="Test" />
  <img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis" />
  <img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="license: MIT" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

--- 

## Overview

The goal of this package is to provide a repository pattern that is agnostic for any given data 
backend.

This design pattern (which comes from [Domain-driven Design](https://en.wikipedia.org/wiki/Domain-driven_design)) 
helps to write data layers without having to know the data backend.
This package abstracts all the aspects of the pattern into a single consistent API.

### Entity

A `Entity` class is the base of the data model part of the repository pattern. The class defines 
how data from a backend should be read and it serves as a reference to that data on the backend.

#### Defining an Entity

```dart
class MovieEntity extends Entity {
  MovieEntity({
    this.id,
    required this.title,
  });

  factory MovieEntity.fromJSON(Map<String, dynamic> data) {
    return MovieEntity(
      id: data['id'] as int?,
      title: data['title'] as String? ?? 'No title',
    );
  }

  int? id;

  String title;

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'title': title,
    };
  }

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}
```

### Deposit

A `Deposit` is a class that provides a single consistent API for the repository pattern. It uses 
an `Entity` as a relation on how to read and write data to any given data backend. 

A `Deposit` class has a reference to table/collection on the data backend from which it can read 
and write data.

#### Creating a Deposit

You can create a `Deposit` in two different ways. The first one is by extending from the class 
itself, this allows for adding custom methods tailed to any specific usecase:

```dart
class MovieDeposit extends Deposit<MovieEntity, int> {
  MovieDeposit() : super('movies', MovieEntity.fromJSON, adapter: OptionalDepositAdapter());
}
```

The `Deposit` class can also be used directly, while this is not recommend there is also nothing 
against it:

```dart
final movieDeposit = Deposit<MovieEntity, int>('movies', MovieEntity.fromJSON);
```

### DepositAdapter

The `DepositAdapter` is an agnostic class that defines how a `Deposit` instance should talk to a 
data backend. By default a `Deposit` instance will use the `Deposit.defaultAdapter` if no adapter 
was passed on initialization. 

The `deposit` package comes with an in-memory adapter called `MemoryDepositAdapter`. But there is 
by default no adapter set, this should be done explicitly by the package user.

The following data backends are officially supported:

- [deposit_firebase](https://pub.dev/packages/deposit_firebase)
- [deposit_supabase](https://pub.dev/packages/deposit_supabase)

#### Setting the default adapter

By setting the `Deposit.defaultAdapter` any `Deposit` instance that did not receive an `adapter` 
on initialization will use the default adapter:

```dart
Deposit.defaultAdapter = MemoryDepositAdapter();
```
