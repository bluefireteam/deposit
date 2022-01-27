/// An entity is a representation of the data in the backend.
abstract class Entity {
  /// Construct a new Entity.
  const Entity();

  /// Return data as JSON.
  Map<String, dynamic> toJSON();
}
