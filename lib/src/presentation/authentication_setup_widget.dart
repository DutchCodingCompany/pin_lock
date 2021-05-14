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
      child: BlocBuilder<SetuplocalauthCubit, SetupStage>(
        builder: (context, state) => state.map(
          base: (base) {
            return overviewBuilder(
              OverviewConfiguration(
                onTogglePin: () {
                  if (base.isPinAuthEnabled == false) {
                    BlocProvider.of<SetuplocalauthCubit>(context).startEnablingPincode();
                  } else if (base.isPinAuthEnabled == true) {
                    BlocProvider.of<SetuplocalauthCubit>(context).startDisablingPincode();
                  }
                },
                onToggleBiometric: () => bloc(context).toggleBiometricAuthentication(),
                onPasswordChangeRequested: () {
                  BlocProvider.of<SetuplocalauthCubit>(context).startChangingPincode();
                },
                isLoading: base.isLoading,
                isBiometricAuthAvailable: base.isBiometricAuthAvailable,
                isBiometricAuthEnabled: base.isBiometricAuthEnabled,
                isPinEnabled: base.isPinAuthEnabled,
                error: base.error,
              ),
            );
          },
          enabling: (s) => enablingWidget(
            EnablingPinConfiguration(
              pinInputWidget: PinInputWidget(
                value: s.pin ?? '',
                pinLength: s.pinLength,
                onInput: (text) => bloc(context).pinEntered(text),
                autofocus: true,
                inputNodeBuilder: pinInputBuilder,
              ),
              pinConfirmationWidget: PinInputWidget(
                value: s.confirmationPin ?? '',
                pinLength: authenticator.pinLength,
                onInput: (text) => bloc(context).pinConfirmationEntered(text),
                inputNodeBuilder: pinInputBuilder,
              ),
              canSubmitChange: s.canGoFurther,
              onSubmitChange: () => BlocProvider.of<SetuplocalauthCubit>(context).savePin(),
              error: s.error,
            ),
          ),
          disabling: (s) => disablingWidget(
            DisablingPinConfiguration(
              pinInputWidget: PinInputWidget(
                value: s.pin,
                pinLength: s.pinLength,
                onInput: (text) => bloc(context).enterPinToDisable(text),
                inputNodeBuilder: pinInputBuilder,
                autofocus: true,
              ),
              canSubmitChange: s.canGoFurther,
              onChangeSubmitted: () => bloc(context).disablePinAuthentication(),
            ),
          ),
          changingPasscode: (s) => changingWidget(
            ChangingPinConfiguration(
              oldPinInputWidget: PinInputWidget(
                inputNodeBuilder: pinInputBuilder,
                pinLength: s.pinLength,
                onInput: (text) => bloc(context).enterPinToChange(text),
                value: s.currentPin,
              ),
              newPinInputWidget: PinInputWidget(
                value: s.newPin,
                pinLength: s.pinLength,
                onInput: (text) => bloc(context).enterNewPin(text),
                inputNodeBuilder: pinInputBuilder,
              ),
              confirmNewPinInputWidget: PinInputWidget(
                  value: s.confirmationPin,
                  pinLength: s.pinLength,
                  onInput: (text) => bloc(context).pinConfirmationEntered(text),
                  inputNodeBuilder: pinInputBuilder),
              error: s.error,
              canSubmitChange: s.canGoFurther,
              onSubimtChange: () => bloc(context).changePin(),
            ),
          ),
        ),
      ),
    );
  }

  SetuplocalauthCubit bloc(BuildContext context) => BlocProvider.of<SetuplocalauthCubit>(context);
}
