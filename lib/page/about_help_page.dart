import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/asset_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/widget/markdown_widget.dart';

class AboutHelpPage extends StatelessWidget {
  const AboutHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    var assets = BlocProvider.of<AssetCubit>(context);
    return Expanded(
      child: Column(
        children: [
          MarkdownWidget(markdownContent: assets.aboutAsset),
          Row(
            children: [
              Text(
                IntifaceLocalizations.needHelp,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  BlocProvider.of<NavigationCubit>(context).goSendLogs();
                },
                child: Text(IntifaceLocalizations.sendLogsForSupport),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
