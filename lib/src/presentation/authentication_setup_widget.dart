import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/blocs/cubit/setup_local_auth_cubit.dart';
import 'package:pin_lock/src/blocs/cubit/setup_stage.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/presentation/builders.dart';
import 'package:pin_lock/src/presentation/widget_configurations.dart';
import 'package:pin_lock/src/presentation/widgets/pin_input_widget.dart';

class AuthenticationSetupWidget extends StatelessWidget {
  final Authenticator authenticator;
  final OverviewBuilder overviewBuilder;
  final EnablingPinWidgetBuilder enablingWidget;
  final DisablingPinWidgetBuilder disablingWidget;
  final PinInputBuilder? pinInputBuilder;

  const AuthenticationSetupWidget({
    Key? key,
    required this.authenticator,
    required this.overviewBuilder,
    required this.enablingWidget,
    required this.disablingWidget,
    this.pinInputBuilder,
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
                onPasswordChangeRequested: () {
                  BlocProvider.of<SetuplocalauthCubit>(context).startChangingPincode();
                },
                isLoading: base.isLoading,
                isBiometricAuthAvailable: base.isBiometricAuthAvailable,
                isBiometricAuthEnabled: base.isBiometricAuthEnabled,
                isPinEnabled: base.isPinAuthEnabled,
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
          changingPasscode: (s) => ChangingWidget(data: s),
        ),
      ),
    );
  }

  SetuplocalauthCubit bloc(BuildContext context) => BlocProvider.of<SetuplocalauthCubit>(context);
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
