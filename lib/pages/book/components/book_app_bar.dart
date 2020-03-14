import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flutter/material.dart';

class BookAppBar extends StatefulWidget {
  final Widget coverImg;

  const BookAppBar({Key key, this.coverImg}) : super(key: key);
  @override
  _BookAppBarState createState() => _BookAppBarState();
}

class _BookAppBarState extends State<BookAppBar> {
  ImageStream coverImageStream;
  double coverImgHeight;

  @override
  void didUpdateWidget(BookAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverImg != widget.coverImg && widget.coverImg is Image) {
      coverImageStream =
          (widget.coverImg as Image).image.resolve(new ImageConfiguration());
      coverImageStream.addListener(ImageStreamListener(imageStreamListener));
    }
  }

  void imageStreamListener(ImageInfo info, bool _) {
    if (mounted) {
      setState(() {
        coverImgHeight = (info.image.height.toDouble() *
                (MediaQuery.of(context).size.width /
                    info.image.width.toDouble()) -
            24);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).cardColor
          : null,
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: coverImgHeight ?? 150,
      title: widget.coverImg == null
          ? Text('Нет обложки')
          : Text(''),
      flexibleSpace: FlexibleSpaceBar(
        background: widget.coverImg,
      ),
      elevation: 0,
      textTheme: Theme.of(context).textTheme,
      iconTheme: Theme.of(context).iconTheme,
      actionsIconTheme: Theme.of(context).iconTheme,
      brightness: Theme.of(context).brightness,
      bottom: DsAppBarBottomDivider(),
    );
  }
}
