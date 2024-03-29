class Location {
  Location(
    this.x,
    this.y,
    this.z,
  );
  double x;
  double y;
  double z;

  @override
  String toString() {
    return "Location : $x, $y , $z";
  }
}
