import "package:job_market/data/models/auth/profile_model.dart";
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthenticatedUser {
  final User? supabaseUser;
  final ProfileUser? profile;

  AuthenticatedUser({this.supabaseUser, this.profile});

  bool get isAuthenticated => supabaseUser != null;
  bool get hasProfile => profile != null;
  bool get isFullProfile => supabaseUser != null && profile != null;
}