import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:sentry/sentry_io.dart';

class SendLogsPage extends StatelessWidget {
  const SendLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var contactController = TextEditingController();
    var textController = TextEditingController();
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Text(
                IntifaceLocalizations.sendLogsToDevs,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                IntifaceLocalizations.submitLogsDescription,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: TextField(
                  controller: contactController,
                  minLines: 1,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: IntifaceLocalizations.putContactInfo,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TextField(
                    controller: textController,
                    minLines: 2,
                    maxLines: null,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: IntifaceLocalizations.putIssueReport,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  child: const Text(IntifaceLocalizations.sendLogs),
                  onPressed: () {
                    var contactText = contactController.value.text;
                    var messageText = textController.value.text;

                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        var contentText = IntifaceLocalizations.sendingLogs;
                        var sendFinished = false;
                        var sendFailed = false;
                        var sendStarted = false;

                        return StatefulBuilder(
                          builder: (context, setState) {
                            if (!sendStarted) {
                              sendStarted = true;
                              Sentry.captureMessage(
                                    """Contact Info: $contactText

Message:

$messageText""",
                                    withScope: (scope) {
                                      scope.setTag(
                                        "ManualLogSubmit",
                                        true.toString(),
                                      );
                                    },
                                  )
                                  .then((value) {
                                    setState(() {
                                      contentText = IntifaceLocalizations.logsSent;
                                      sendFinished = true;
                                    });
                                  })
                                  .onError((error, stackTrace) {
                                    setState(() {
                                      contentText =
                                          IntifaceLocalizations.errorSendingLogs;
                                      sendFinished = true;
                                      sendFailed = true;
                                    });
                                  });
                            }
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[Text(contentText)],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: sendFinished
                                      ? () {
                                          Navigator.of(context).pop();
                                          if (!sendFailed) {
                                            BlocProvider.of<NavigationCubit>(
                                              context,
                                            ).goSettings();
                                          }
                                        }
                                      : null,
                                  child: Text(IntifaceLocalizations.ok),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
