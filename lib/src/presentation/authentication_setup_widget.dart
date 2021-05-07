import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_local_auth_cubit.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticationSetupWidget extends StatelessWidget {
  final Authenticator authenticator;

  const AuthenticationSetupWidget({Key? key, required this.authenticator}) : super(key: key);
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
                if (base.isPinAuthEnabled == false) {
                  BlocProvider.of<SetuplocalauthCubit>(context).startEnablingPincode();
                } else if (base.isPinAuthEnabled == true) {
                  BlocProvider.of<SetuplocalauthCubit>(context).startDisablingPincode();
                }
              },
              onChangePasscode: () {
                BlocProvider.of<SetuplocalauthCubit>(context).startChangingPincode();
              },
            );
          },
          enabling: (s) => EnablingWidget(data: s),
          disabling: (s) => DisablingWidget(data: s),
          changingPasscode: (s) => ChangingWidget(data: s),
        ),
      ),
    );
  }
}

class ChangingWidget extends StatefulWidget {
  final ChangingPasscode data;

  const ChangingWidget({Key? key, required this.data}) : super(key: key);

  @override
  _ChangingWidgetState createState() => _ChangingWidgetState();
}

class _ChangingWidgetState extends State<ChangingWidget> {
  late final FocusNode _currentPinFocusNode;
  late final FocusNode _newPinFocusNode;
  late final FocusNode _confirmPinFocusNode;
  @override
  void initState() {
    super.initState();
    _currentPinFocusNode = FocusNode()..requestFocus();
    _newPinFocusNode = FocusNode();
    _confirmPinFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SetuplocalauthCubit>(context);
    return Column(
      children: [
        const Text('Enter current pin'),
        PinInputWidget(
          value: widget.data.currentPin,
          pinLength: widget.data.pinLength,
          focusNode: _currentPinFocusNode,
          nextFocusNode: _newPinFocusNode,
          onInput: (text) {
            bloc.enterPinToChange(text);
          },
        ),
        if (_isCurrentPinIssue(widget.data.error))
          Text(
            widget.data.error!.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        const Text('Enter new pin'),
        PinInputWidget(
          value: widget.data.newPin,
          pinLength: widget.data.pinLength,
          focusNode: _newPinFocusNode,
          nextFocusNode: _confirmPinFocusNode,
          onInput: (text) {
            bloc.enterNewPin(text);
          },
        ),
        const Text('confirm new pin'),
        PinInputWidget(
          value: widget.data.confirmationPin,
          pinLength: widget.data.pinLength,
          focusNode: _confirmPinFocusNode,
          onInput: (text) {
            bloc.enterConfirmationPin(text);
          },
        ),
        if (widget.data.error != null && !_isCurrentPinIssue(widget.data.error))
          Text(
            widget.data.error!.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        if (widget.data.canGoFurther)
          TextButton(
            onPressed: () => bloc.changePin(),
            child: const Text('save'),
          )
      ],
    );
  }

  bool _isCurrentPinIssue(LocalAuthFailure? error) {
    return error is WrongPin || error is TooManyAttempts;
  }
}

class DisablingWidget extends StatelessWidget {
  final Disabling data;

  const DisablingWidget({Key? key, required this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PinInputWidget(
          value: data.pin,
          pinLength: data.pinLength,
          focusNode: FocusNode()..requestFocus(),
          onInput: (text) {
            BlocProvider.of<SetuplocalauthCubit>(context).enterPinToDisable(text);
          },
        ),
        if (data.error != null) Text(data.error.toString(), style: const TextStyle(color: Colors.red)),
        TextButton(
          onPressed:
              data.canGoFurther ? () => BlocProvider.of<SetuplocalauthCubit>(context).disablePinAuthentication() : null,
          child: const Text('save'),
        ),
      ],
    );
  }
}

class EnablingWidget extends StatefulWidget {
  final Enabling data;

  const EnablingWidget({Key? key, required this.data}) : super(key: key);

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
          pinLength: widget.data.pinLength,
          focusNode: pinFocusNode,
          nextFocusNode: confirmFocusNode,
          onInput: (pinText) => bloc.pinEntered(pinText),
        ),
        PinInputWidget(
          value: widget.data.confirmationPin ?? '',
          pinLength: widget.data.pinLength,
          focusNode: confirmFocusNode,
          onInput: (confirmationText) {
            bloc.pinConfirmationEntered(confirmationText);
          },
        ),
        TextButton(
          onPressed: widget.data.canGoFurther ? () => bloc.savePin() : null,
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
  final void Function()? onChangePasscode;

  const BaseWidget({
    Key? key,
    this.isPinEnabled,
    this.isBiometricAvailable,
    this.isBiometricEnabled,
    required this.onToggle,
    this.onChangePasscode,
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
        if (isPinEnabled == true && isBiometricAvailable != null)
          TextButton(onPressed: onChangePasscode, child: const Text('change passcode')),
      ],
    );
  }
}
