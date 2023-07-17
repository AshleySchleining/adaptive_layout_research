import 'package:adaptive_layout_research/flutter_adaptive_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Layout Demo',
      routes: <String, Widget Function(BuildContext)>{
        _ExtractRouteArguments.routeName: (_) => const _ExtractRouteArguments()
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, ChangeNotifier {
  Map<int, SlotWidthDefinition> bodySlotWidths = {
    1: const SlotWidthDefinition(),
    2: const SlotWidthDefinition.constant(300),
    3: const SlotWidthDefinition.constant(300),
  };

  Map<int, SlotWidthDefinition> sBodySlotWidths = {
    1: const SlotWidthDefinition(),
    2: const SlotWidthDefinition(),
    3: const SlotWidthDefinition(),
  };

  Map<int, SlotWidthDefinition> tBodySlotWidths = {
    1: const SlotWidthDefinition(),
    2: const SlotWidthDefinition.constant(300),
    3: const SlotWidthDefinition.constant(300),
  };

  // The index of the selected mail card.
  int? selected;
  void selectCard(int? index) {
    setState(() {
      selected = index;
    });
  }

  bool showExtraDetails = false;
  void moreDetailsCallback() {
    setState(() {
      showExtraDetails = !showExtraDetails;
    });
  }

  Map<SlotIds, SlotLayout?> get navigationSlots {
    return <SlotIds, SlotLayout?>{
      SlotIds.topNavigation: SlotLayout(config: <Breakpoint, SlotLayoutConfig?>{
        Breakpoints.standard: SlotLayout.from(
            key: const Key('topNavigation'),
            builder: (_) {
              return Container(
                  width: double.infinity,
                  color: Colors.green,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Top Navigation'),
                  ));
            }),
        Breakpoints.mediumWeb: SlotLayout.from(
            key: const Key('topNavigation'),
            builder: (_) {
              return Container(
                  width: double.infinity,
                  color: Colors.orange,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Top Navigation only on the web'),
                  ));
            })
      }),
      SlotIds.bottomNavigation:
          SlotLayout(config: <Breakpoint, SlotLayoutConfig?>{
        Breakpoints.standard: SlotLayout.from(
            key: const Key('bottomNavigation'),
            builder: (_) {
              return Container(
                  width: double.infinity,
                  color: Colors.blue,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Bottom Navigation'),
                  ));
            })
      }),
      SlotIds.secondaryNavigation:
          SlotLayout(config: <Breakpoint, SlotLayoutConfig?>{
        Breakpoints.standard: SlotLayout.from(
            key: const Key('bottomNavigation'),
            builder: (_) {
              return Container(width: 50, color: Colors.red);
            })
      }),
      SlotIds.primaryNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig?>{
          Breakpoints.medium: SlotLayout.from(
            key: const Key('primaryNavigation'),
            builder: (_) {
              return Container(width: 50, color: Colors.amber);
            },
          ),
          Breakpoints.large: SlotLayout.from(
            key: const Key('Large primaryNavigation'),
            builder: (_) {
              return Container(width: 100, color: Colors.amberAccent);
            },
          ),
        },
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 227, 241),
      body: AdaptiveLayout(
        includeBorders: true,
        borderWidth: 2.0,
        borderColor: Colors.black87,
        bodySlotWidths: bodySlotWidths,
        secondaryBodySlotWidths: sBodySlotWidths,
        tertiaryBodySlotWidths: tBodySlotWidths,
        navigationSlotDefinitions: navigationSlots,
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              builder: (_) => Scaffold(
                backgroundColor: Colors.cyan,
                body: DeveloperList(
                  selected: selected,
                  items: developers,
                  selectCard: selectCard,
                  moreDetailsCallback: moreDetailsCallback,
                ),
              ),
            ),
          },
        ),
        secondaryBody: selected != null
            ? SlotLayout(
                config: <Breakpoint, SlotLayoutConfig?>{
                  Breakpoints.mediumAndUp: SlotLayout.from(
                    key: const Key('Secondary Body'),
                    builder: (_) => SafeArea(
                      child: DetailTile(
                        item: developers[selected ?? 0],
                        moreDetailsCallback: moreDetailsCallback,
                      ),
                    ),
                  )
                },
              )
            : null,
        tertiaryBody: showExtraDetails
            ? SlotLayout(config: <Breakpoint, SlotLayoutConfig?>{
                Breakpoints.mediumAndUp: SlotLayout.from(
                  key: const Key('Tertiary Body'),
                  builder: (_) => const MoreDetailsPage(),
                )
              })
            : null,
      ),
    );
  }
}

typedef CardSelectedCallback = void Function(int?);

class DeveloperList extends StatelessWidget {
  const DeveloperList({
    super.key,
    required this.items,
    required this.selectCard,
    required this.selected,
    required this.moreDetailsCallback,
  });

  final List<Developer> items;
  final int? selected;
  final CardSelectedCallback selectCard;
  final VoidCallback moreDetailsCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => DeveloperListTile(
              item: items[index],
              selectCard: selectCard,
              selected: selected,
              moreDetailsCallback: moreDetailsCallback,
            ),
          ),
        ),
      ],
    );
  }
}

class MoreDetailsPage extends StatelessWidget {
  const MoreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(child: Text('More Details go here...')));
  }
}

class DeveloperListTile extends StatelessWidget {
  const DeveloperListTile({
    super.key,
    required this.item,
    required this.selectCard,
    required this.selected,
    required this.moreDetailsCallback,
  });

  final Developer item;
  final int? selected;
  final CardSelectedCallback selectCard;
  final VoidCallback moreDetailsCallback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // The behavior of opening a detail view is different on small screens
        // than large screens.
        // Small screens open a modal with the detail view while large screens
        // simply show the details on the secondaryBody.
        selectCard(developers.indexOf(item));
        if (!Breakpoints.mediumAndUp.isActive(context)) {
          Navigator.of(context).pushNamed(_ExtractRouteArguments.routeName,
              arguments: _ScreenArguments(
                  item: item,
                  selectCard: selectCard,
                  moreDetailsCallback: moreDetailsCallback));
        } else {
          selectCard(developers.indexOf(item));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: selected == developers.indexOf(item)
                ? const Color.fromARGB(255, 234, 222, 255)
                : const Color.fromARGB(255, 243, 237, 247),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('${item.firstName} ${item.lastName}'),
          ),
        ),
      ),
    );
  }
}

class DetailTile extends StatelessWidget {
  const DetailTile({
    super.key,
    required this.item,
    required this.moreDetailsCallback,
  });

  final VoidCallback moreDetailsCallback;
  final Developer item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.minWidth < 100) {
          return Container(color: Colors.greenAccent);
        }
        return Container(
          color: Colors.greenAccent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Detail info'),
                  Text('${item.firstName} ${item.lastName}'),
                  Text(item.detailInfo),
                  const SizedBox(
                    height: 100,
                  ),
                  OutlinedButton(
                    onPressed: moreDetailsCallback,
                    child: const Text('More...'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// The ScreenArguments used to pass arguments to the RouteDetailView as a named
// route.
class _ScreenArguments {
  _ScreenArguments({
    required this.item,
    required this.selectCard,
    required this.moreDetailsCallback,
  });
  final Developer item;
  final CardSelectedCallback selectCard;
  final VoidCallback moreDetailsCallback;
}

class _ExtractRouteArguments extends StatelessWidget {
  const _ExtractRouteArguments();

  static const String routeName = '/detailView';

  @override
  Widget build(BuildContext context) {
    final _ScreenArguments args =
        ModalRoute.of(context)!.settings.arguments! as _ScreenArguments;

    return RouteDetailView(
        item: args.item,
        selectCard: args.selectCard,
        moreDetailsCallback: args.moreDetailsCallback);
  }
}

class RouteDetailView extends StatelessWidget {
  const RouteDetailView({
    super.key,
    required this.item,
    required this.selectCard,
    required this.moreDetailsCallback,
  });

  final Developer item;
  final CardSelectedCallback selectCard;
  final VoidCallback moreDetailsCallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () {
                Navigator.popUntil(context,
                    (Route<dynamic> route) => route.settings.name == '/');
                selectCard(null);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
              child: DetailTile(
                  item: item, moreDetailsCallback: moreDetailsCallback)),
        ],
      ),
    );
  }
}

const List<Developer> developers = <Developer>[
  Developer(
      firstName: 'Phil',
      lastName: 'Muhlenkamp',
      detailInfo: 'Flutter/iOS Developer'),
  Developer(
      firstName: 'Chris',
      lastName: 'Gonzales',
      detailInfo: 'Flutter/iOS Developer'),
  Developer(
      firstName: 'Ashley',
      lastName: 'Schleining',
      detailInfo: 'Flutter/iOS Developer'),
];

class Developer {
  final String firstName;
  final String lastName;
  final String detailInfo;

  const Developer({
    required this.firstName,
    required this.lastName,
    required this.detailInfo,
  });
}

// class VerticalSplitView extends StatefulWidget {
//   final Widget left;
//   final Widget right;
//   final double ratio;

//   const VerticalSplitView(
//       {Key? key, required this.left, required this.right, this.ratio = 0.5})
//       : assert(ratio >= 0),
//         assert(ratio <= 1),
//         super(key: key);

//   @override
//   _VerticalSplitViewState createState() => _VerticalSplitViewState();
// }

// class _VerticalSplitViewState extends State<VerticalSplitView> {
//   final _dividerWidth = 12.0;

//   //from 0-1
//   late double _ratio;

//   @override
//   void initState() {
//     _ratio = widget.ratio;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, BoxConstraints constraints) {
//       double? _maxWidth;
//       if (_maxWidth == null) _maxWidth = constraints.maxWidth - _dividerWidth;
//       if (_maxWidth != constraints.maxWidth) {
//         _maxWidth = constraints.maxWidth - _dividerWidth;
//       }

//       return SizedBox(
//         width: constraints.maxWidth,
//         child: Row(
//           children: <Widget>[
//             SizedBox(
//               width: _ratio * _maxWidth,
//               child: widget.left,
//             ),
//             GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               child: SizedBox(
//                 width: _dividerWidth,
//                 height: constraints.maxHeight,
//                 child: RotationTransition(
//                   child: Icon(Icons.drag_handle),
//                   turns: AlwaysStoppedAnimation(0.25),
//                 ),
//               ),
//               onHorizontalDragUpdate: (DragUpdateDetails details) {
//                 setState(() {
//                   _ratio += details.delta.dx / _maxWidth!;
//                   if (_ratio > 1)
//                     _ratio = 1;
//                   else if (_ratio < 0.0) _ratio = 0.0;
//                 });
//               },
//             ),
//             SizedBox(
//               width: (1 - _ratio) * _maxWidth,
//               child: widget.right,
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
