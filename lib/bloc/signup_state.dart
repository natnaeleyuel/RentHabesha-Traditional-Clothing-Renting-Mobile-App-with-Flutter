abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupData extends SignupState {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final String address;
  final int currentStep;

  SignupData({
    this.name = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.gender = '',
    this.address = '',
    this.currentStep = 1,
  });

  SignupData copyWith({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? gender,
    String? address,
    int? currentStep,
  }) {
    return SignupData(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class SignupLoading extends SignupState {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final String address;

  SignupLoading({
    this.name = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.gender = '',
    this.address = '',
  });

  @override
  List<Object?> get props => [name, email, password, phone, gender, address];
}

class SignupSuccess extends SignupState {
  final Map<String, dynamic> userData;

  SignupSuccess(this.userData);

  @override
  List<Object?> get props => [userData];
}

class SignupError extends SignupState {
  final String message;
  SignupError(this.message);
}


