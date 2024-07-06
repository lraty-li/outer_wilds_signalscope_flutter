import 'package:flutter/material.dart';

final List<
    ({
      String name,
      double radius,
      double orbitalRadius,
      MaterialColor color,
      ({double x, double y, double z}) location
    })> planetsData = [
  // name ;
  //Radius (m) (most stable flat ground) ;
  // Orbital radius to sun (m);
  // inital location
  (
    name: "Timber Hearth",
    radius: 254,
    orbitalRadius: 8593.085981,
    color: Colors.green,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    // The center of ET/AT
    name: "Ember Twins",
    radius: 170,
    orbitalRadius: 5000,
    color: Colors.red,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Brittle Hollow",
    radius: 272,
    orbitalRadius: 11690.89092,
    color: Colors.purple,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Dart Bramble",
    radius: 203.3,
    orbitalRadius: 20000,
    color: Colors.amber,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Giant's deep",
    radius: 500,
    orbitalRadius: 16457.58738,
    color: Colors.blue,
    location: (x: 0, y: 0, z: 0)
  ),
  // (
  //   name: "The Stranger",
  //   radius: 0,
  //   orbitalRadius: 1,
  //   color: 0x5D5F45,
  //   location: (x: 0, y: 0, z: 0)
  // ), //游戏中会开船飞走
];

final List<
    ({
      String name,
      double radius,
      double orbitalRadius,
      ({double x, double y, double z}) location
    })> quantumMoonData = [
  (
    name: "Quantum Moon - Timber Hearth",
    radius: 73,
    orbitalRadius: 1100,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Quantum Moon - Ember Twins",
    radius: 73,
    orbitalRadius: 1700,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Quantum Moon - Brittle Hollow",
    radius: 73,
    orbitalRadius: 1400,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Quantum Moon - Dart Bramble",
    radius: 73,
    orbitalRadius: 1500,
    location: (x: 0, y: 0, z: 0)
  ),
  (
    name: "Quantum Moon - Giant's deep",
    radius: 73,
    orbitalRadius: 1500,
    location: (x: 0, y: 0, z: 0)
  ),
];
