import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:pin_lock/src/blocs/cubit/setup_local_auth_cubit.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/presentation/pin_input.dart';
import 'package:pin_lock/src/presentation/setup/builders.dart';
import 'package:pin_lock/src/presentation/setup/configurations.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

/// A widget that controls the setup of local authentication.
/// The builders passed as parameters to this widget describe what the UI
/// should look like at each step of the setup.
/// [AuthenticationSetupWidget] takes care of invoking appropriate builders
/// so that the app only takes care of what the setup should look like,
/// while the package takes care of the logic behind it.
class AuthenticationSetupWidget extends StatelessWidget {
  /// App's instace of [Authenticator]
  final Authenticator authenticator;

  /// Builder that describes what the passive, overview state should look like, with
  /// regards to the given [OverviewConfiguration]
  final OverviewBuilder overviewBuilder;

  /// Builder that describes UI configuration with regards to provided [EnablingPinConfiguration]
  final EnablingPinWidgetBuilder enablingWidget;

  /// Builder that describes UI configuration with regards to provided [DisablingPinConfiguration]
  final DisablingPinWidgetBuilder disablingWidget;

  /// Builder that describes UI configuration with regards to provided [ChangingPinConfiguration]
  final ChangingPinWidgetBuilder changingWidget;

  /// Builder that describes what pin input fields look like given the [InputFieldState]
  final PinInputBuilder pinInputBuilder;

  const AuthenticationSetupWidget({
    Key? key,
    required this.authenticator,
    required this.overviewBuilder,
    required this.enablingWidget,
    required this.disablingWidget,
    required this.changingWidget,
    required this.pinInputBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetuplocalauthCubit>(
      create: (context) =>
          SetuplocalauthCubit(authenticator)..checkInitialState(),
      child: BlocBuilder<SetuplocalauthCubit, SetupStage>(
          builder: (context, state) {
        if (state is Base) {
          return overviewBuilder(
            OverviewConfiguration(
              onTogglePin: () {
                if (state.isPinAuthEnabled == false) {
                  bloc(context).startEnablingPincode();
                } else if (state.isPinAuthEnabled == true) {
                  bloc(context).startDisablingPincode();
                }
              },
              onToggleBiometric: () =>
                  bloc(context).toggleBiometricAuthentication(),
              onPasswordChangeRequested: () =>
                  bloc(context).startChangingPincode(),
              isLoading: state.isLoading,
              isBiometricAuthAvailable: state.isBiometricAuthAvailable,
              isBiometricAuthEnabled: state.isBiometricAuthEnabled,
              isPinEnabled: state.isPinAuthEnabled,
              error: state.error,
              onRefresh: () => bloc(context).checkInitialState(),
            ),
          );
        }
        if (state is Enabling) {
          return enablingWidget(
            EnablingPinConfiguration(
              pinInputWidget: PinInputWidget(
                value: state.pin ?? '',
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).pinEntered(text),
                autofocus: true,
                inputNodeBuilder: pinInputBuilder,
                hasError: state.error != null,
              ),
              pinConfirmationWidget: PinInputWidget(
                value: state.confirmationPin ?? '',
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).pinConfirmationEntered(text),
                inputNodeBuilder: pinInputBuilder,
                hasError: state.error != null,
              ),
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onSubmitChange: () => bloc(context).savePin(),
              error: state.error,
              onCancel: () => bloc(context).checkInitialState(),
            ),
          );
        }
        if (state is Disabling) {
          return disablingWidget(
            DisablingPinConfiguration(
              pinInputWidget: PinInputWidget(
                value: state.pin,
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).enterPinToDisable(text),
                inputNodeBuilder: pinInputBuilder,
                autofocus: true,
                hasError: state.error != null,
              ),
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onChangeSubmitted: () => bloc(context).disablePinAuthentication(),
              onCancel: () => bloc(context).checkInitialState(),
              error: state.error,
            ),
          );
        }
        if (state is ChangingPasscode) {
          return changingWidget(
            ChangingPinConfiguration(
              oldPinInputWidget: PinInputWidget(
                inputNodeBuilder: pinInputBuilder,
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).enterPinToChange(text),
                value: state.currentPin,
                hasError: state.error != null &&
                    state.error != LocalAuthFailure.pinNotMatching,
              ),
              newPinInputWidget: PinInputWidget(
                value: state.newPin,
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).enterNewPin(text),
                inputNodeBuilder: pinInputBuilder,
                hasError: state.error == LocalAuthFailure.pinNotMatching,
              ),
              confirmNewPinInputWidget: PinInputWidget(
                value: state.confirmationPin,
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).enterConfirmationPin(text),
                inputNodeBuilder: pinInputBuilder,
                hasError: state.error == LocalAuthFailure.pinNotMatching,
              ),
              error: state.error,
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onSubimtChange: () => bloc(context).changePin(),
              onCancel: () => bloc(context).checkInitialState(),
            ),
          );
        }
        return Container();
      }),
    );
  }

  SetuplocalauthCubit bloc(BuildContext context) =>
      BlocProvider.of<SetuplocalauthCubit>(context);
}
