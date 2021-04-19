import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

part 'setup_local_auth_state.dart';

class SetuplocalauthCubit extends Cubit<SetupLocalAuthState> {
  SetuplocalauthCubit() : super(Loading());
}
