import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_local_auth_cubit.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/presentation/builders.dart';
import 'package:pin_lock/src/presentation/widget_configurations.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticationSetupWidget extends StatelessWidget {
  final Authenticator authenticator;
  final OverviewBuilder overviewBuilder;
  final EnablingPinWidgetBuilder enablingWidget;
  final DisablingPinWidgetBuilder disablingWidget;
  final ChangingPinWidgetBuilder changingWidget;
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
      create: (context) => SetuplocalauthCubit(authenticator)..checkInitialState(),
      child: BlocBuilder<SetuplocalauthCubit, SetupStage>(builder: (context, state) {
        if (state is Base) {
          return overviewBuilder(
            OverviewConfiguration(
              onTogglePin: () {
                if (state.isPinAuthEnabled == false) {
                  BlocProvider.of<SetuplocalauthCubit>(context).startEnablingPincode();
                } else if (state.isPinAuthEnabled == true) {
                  BlocProvider.of<SetuplocalauthCubit>(context).startDisablingPincode();
                }
              },
              onToggleBiometric: () => bloc(context).toggleBiometricAuthentication(),
              onPasswordChangeRequested: () {
                BlocProvider.of<SetuplocalauthCubit>(context).startChangingPincode();
              },
              isLoading: state.isLoading,
              isBiometricAuthAvailable: state.isBiometricAuthAvailable,
              isBiometricAuthEnabled: state.isBiometricAuthEnabled,
              isPinEnabled: state.isPinAuthEnabled,
              error: state.error,
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
              ),
              pinConfirmationWidget: PinInputWidget(
                value: state.confirmationPin ?? '',
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).pinConfirmationEntered(text),
                inputNodeBuilder: pinInputBuilder,
              ),
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onSubmitChange: () => BlocProvider.of<SetuplocalauthCubit>(context).savePin(),
              error: state.error,
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
              ),
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onChangeSubmitted: () => bloc(context).disablePinAuthentication(),
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
              ),
              newPinInputWidget: PinInputWidget(
                value: state.newPin,
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).enterNewPin(text),
                inputNodeBuilder: pinInputBuilder,
              ),
              confirmNewPinInputWidget: PinInputWidget(
                  value: state.confirmationPin,
                  pinLength: authenticator.pinLength,
                  onInput: (text) => bloc(context).pinConfirmationEntered(text),
                  inputNodeBuilder: pinInputBuilder),
              error: state.error,
              canSubmitChange: state.canGoFurther(authenticator.pinLength),
              onSubimtChange: () => bloc(context).changePin(),
            ),
          );
        }
        return Container();
      }),
    );
  }

  SetuplocalauthCubit bloc(BuildContext context) => BlocProvider.of<SetuplocalauthCubit>(context);
}
