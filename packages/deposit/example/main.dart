import 'package:deposit/deposit.dart';

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
  String toString() => '$id: $title';
}

class MovieDeposit extends Deposit<MovieEntity, int> {
  MovieDeposit() : super('movies', MovieEntity.fromJSON);
}

Future<void> main() async {
  Deposit.defaultAdapter = MemoryDepositAdapter();

  final movieDeposit = MovieDeposit();
  await movieDeposit.add(MovieEntity(title: 'The Godfather'));
  await movieDeposit.add(MovieEntity(title: 'Avatar'));

  final movie = await movieDeposit.getById(1);
  print('Movie id: ${movie.id}');

  print(await movieDeposit.page(orderBy: OrderBy('title', ascending: true)));
}
