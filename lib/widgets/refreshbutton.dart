import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zwiftdataviewer/appkeys.dart';
import 'package:zwiftdataviewer/models/ActivitiesDataModel.dart';

class RefreshButton extends StatelessWidget {
  final bool isActive;

  const RefreshButton({required this.isActive, required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Consumer<ActivitiesDataModel>(
          builder: (context, model, _) {
            return IconButton(
              key: AppKeys.refreshButton,
              tooltip:
                  'refresh', //ArchSampleLocalizations.of(context).filterTodos,
              // initialValue: model.filter,
              // onSelected: (filter) => model.filter = filter,
              // itemBuilder: (BuildContext context) => _items(context, model),
              icon: const Icon(Icons.refresh),
              onPressed: refresh(model, context),
            );
          },
        ),
      ),
    );
  }

  refresh(model, context) {
    // model.loadActivities(context);
  }
}
