import 'package:flutter/material.dart';

import '../theme.dart';

Future<void> showDsModalBottomSheet({
  @required BuildContext context,
  @required Widget Function(BuildContext) builder,
  String title,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ModalSheetTopBar(),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Divider(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 5 / 8,
              ),
              child: builder(context),
            ),
          ],
        ),
      );
    },
  );
}

class _ModalSheetTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kBottomSheetBorderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(kBottomSheetBorderRadius),
        ),
        margin: EdgeInsets.symmetric(
          vertical: kBottomSheetBorderRadius / 2.5,
        ),
        width: MediaQuery.of(context).size.width / 4,
      ),
    );
  }
}
