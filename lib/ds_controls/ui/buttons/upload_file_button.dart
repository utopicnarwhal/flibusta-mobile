import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/utils/drawning.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DsUploadFileButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonLabel;
  final BehaviorSubject<double> uploadProgressController;

  const DsUploadFileButton({
    Key key,
    @required this.onPressed,
    @required this.buttonLabel,
    @required this.uploadProgressController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: uploadProgressController,
      builder: (context, progressSnapshot) {
        return DashedRect(
          color: Theme.of(context).dividerColor,
          strokeWidth: 2,
          radius: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 8, 0),
              title: Text(
                buttonLabel,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: onPressed == null
                          ? Theme.of(context).disabledColor
                          : kSecondaryColor(context),
                    ),
              ),
              trailing: progressSnapshot.hasData
                  ? DsCircularProgressIndicator(
                      value: progressSnapshot.data < 0
                          ? null
                          : progressSnapshot.data,
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: kSecondaryColor(context).withOpacity(0.2),
                      ),
                      child: Icon(
                        EvaIcons.plus,
                        color: kSecondaryColor(context),
                        size: 28,
                      ),
                    ),
              onTap: progressSnapshot.hasData ? null : onPressed,
            ),
          ),
        );
      },
    );
  }
}
