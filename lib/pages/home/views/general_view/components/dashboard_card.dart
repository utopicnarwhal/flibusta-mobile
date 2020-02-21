// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class DashboardCard extends StatefulWidget {
//   final UserContactDataState userContactDataState;

//   const DashboardCard({
//     Key key,
//     @required this.userContactDataState,
//   }) : super(key: key);

//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<DashboardCard> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: 20.0,
//               vertical: 16.0,
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       DashboardCounterBlock(
//                         titleText: widget
//                                 .userContactDataState.userStatistics?.totalSum
//                                 ?.round()
//                                 ?.toString() ??
//                             '0',
//                         userContactDataState: widget.userContactDataState,
//                         totalSum: true,
//                         subtitleText: 'Объем выдач за все время',
//                       ),
//                     ],
//                   ),
//                 ),
//                 RosbankLogo(
//                   sideHeight: 50,
//                   isAnimated: false,
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 DashboardCounterBlock(
//                   titleText: widget
//                           .userContactDataState.userStatistics?.totalLoans
//                           ?.toString() ??
//                       '0',
//                   userContactDataState: widget.userContactDataState,
//                   subtitleText: 'Всего',
//                 ),
//                 SizedBox(
//                   height: 35,
//                   child: VerticalDivider(),
//                 ),
//                 DashboardCounterBlock(
//                   titleText: widget
//                           .userContactDataState.userStatistics?.approvedLoans
//                           ?.toString() ??
//                       '0',
//                   userContactDataState: widget.userContactDataState,
//                   subtitleText: 'Одобрено',
//                 ),
//                 SizedBox(
//                   height: 35,
//                   child: VerticalDivider(),
//                 ),
//                 DashboardCounterBlock(
//                   titleText: widget
//                           .userContactDataState.userStatistics?.issuedLoans
//                           ?.toString() ??
//                       '0',
//                   userContactDataState: widget.userContactDataState,
//                   subtitleText: 'Выдано',
//                 ),
//                 SizedBox(
//                   height: 35,
//                   child: VerticalDivider(),
//                 ),
//                 DashboardCounterBlock(
//                   titleText: widget
//                           .userContactDataState.userStatistics?.refusedLoans
//                           ?.toString() ??
//                       '0',
//                   userContactDataState: widget.userContactDataState,
//                   subtitleText: 'Отказов',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class DashboardCounterBlock extends StatelessWidget {
//   final String titleText;
//   final String subtitleText;
//   final UserContactDataState userContactDataState;
//   final bool totalSum;

//   const DashboardCounterBlock({
//     Key key,
//     this.titleText,
//     this.subtitleText,
//     this.userContactDataState,
//     this.totalSum = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment:
//           totalSum ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               totalSum ? titleText.spaceDevisions() : titleText,
//               style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: totalSum ? FontWeight.w700 : FontWeight.w400),
//             ),
//             if (totalSum)
//               Icon(
//                 FontAwesomeIcons.rubleSign,
//                 size: 21,
//               ),
//           ],
//         ),
//         Text(
//           subtitleText,
//           style: TextStyle(
//             fontSize: totalSum ? 16 : 12,
//           ),
//         ),
//       ],
//     );
//   }
// }
