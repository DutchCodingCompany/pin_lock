import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_local_auth_cubit.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class SetupAuthenticationWidget extends StatelessWidget {
  final Authenticator authenticator;

  const SetupAuthenticationWidget({Key? key, required this.authenticator}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetuplocalauthCubit>(
      create: (context) => SetuplocalauthCubit(authenticator)..checkInitialState(),
      child: BlocBuilder<SetuplocalauthCubit, SetupStage>(
        builder: (context, state) => state.map(
          base: (base) {
            if (base.isLoading) {
              return const CircularProgressIndicator();
            }
            return BaseWidget(
              isPinEnabled: base.isPinAuthEnabled,
              isBiometricAvailable: base.isBiometricAuthAvailable,
              isBiometricEnabled: base.isBiometricAuthEnabled,
              onToggle: () {
                BlocProvider.of<SetuplocalauthCubit>(context).startEnablingPincode();
              },
            );
          },
          enabling: (s) => EnablingWidget(
            data: s,
            pinLength: authenticator.pinLength,
          ),
          disabling: (s) => Container(),
          changingPasscode: (s) => Container(),
        ),
      ),
    );
  }
}

class EnablingWidget extends StatefulWidget {
  final Enabling data;
  final int pinLength;

  const EnablingWidget({Key? key, required this.data, required this.pinLength}) : super(key: key);

  @override
  _EnablingWidgetState createState() => _EnablingWidgetState();
}

class _EnablingWidgetState extends State<EnablingWidget> {
  final pinFocusNode = FocusNode();
  final confirmFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    pinFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SetuplocalauthCubit>(context);
    return Column(
      children: [
        PinInputWidget(
          value: widget.data.pin ?? '',
          pinLength: widget.pinLength,
          focusNode: pinFocusNode,
          onInput: (pinText) {
            bloc.pinEntered(pinText);
            if (pinText.length == bloc.authenticator.pinLength) {
              confirmFocusNode.requestFocus();
            }
          },
        ),
        PinInputWidget(
          value: widget.data.confirmationPin ?? '',
          pinLength: widget.pinLength,
          focusNode: confirmFocusNode,
          onInput: (confirmationText) {
            bloc.pinConfirmationEntered(confirmationText);
          },
        ),
        TextButton(
          onPressed: widget.data.canSave ? () => bloc.savePin() : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class BaseWidget extends StatelessWidget {
  final bool? isPinEnabled;
  final bool? isBiometricAvailable;
  final bool? isBiometricEnabled;
  final void Function() onToggle;

  const BaseWidget({
    Key? key,
    this.isPinEnabled,
    this.isBiometricAvailable,
    this.isBiometricEnabled,
    required this.onToggle,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPinEnabled != null)
          Row(
            children: [
              Text('Pin is enabled: $isPinEnabled'),
              TextButton(onPressed: onToggle, child: Text(isPinEnabled! ? 'Disable' : 'Enable'))
            ],
          ),
        if (isBiometricAvailable != null) Text('Biometric is available: $isBiometricAvailable'),
        if (isBiometricEnabled != null) Text('Biometric is enabled: $isBiometricEnabled'),
      ],
    );
  }
}
