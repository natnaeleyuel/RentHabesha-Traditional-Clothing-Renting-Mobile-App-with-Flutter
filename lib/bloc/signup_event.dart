abstract class SignupEvent {}

class UpdateSignupData extends SignupEvent {
  final String? name;
  final String? email;
  final String? password;
  final String? phone;
  final String? gender;
  final String? address;

  UpdateSignupData({
    this.name,
    this.email,
    this.password,
    this.phone,
    this.gender,
    this.address,
  });
}

class SubmitStep1 extends SignupEvent {}

class SubmitStep2 extends SignupEvent {}

class SubmitStep3 extends SignupEvent {}



