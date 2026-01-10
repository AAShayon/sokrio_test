import 'package:equatable/equatable.dart';

abstract class User extends Equatable {
  int get id;
  String get email;
  String get firstName;
  String get lastName;
  String get avatar;

  const User();

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, email, firstName, lastName, avatar];
}
