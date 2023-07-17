import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'breakpoints.dart';
import 'slot_layout.dart';

/// Defines how a body type slot should be sized horizontally. It can be either
/// given a constant width, a percentage of the available width (after constant)
/// width slots have been accounted for, or lastly, the entire available width
/// divided equally amongst the remaining slots.
class SlotWidthDefinition {
  final double? constantWidth;
  final double? percentageWidth;

  const SlotWidthDefinition.constant(this.constantWidth)
      : percentageWidth = null;
  const SlotWidthDefinition.percentage(this.percentageWidth)
      : constantWidth = null;
  const SlotWidthDefinition()
      : constantWidth = null,
        percentageWidth = null;

  bool get isConstantWidth => constantWidth != null;
  bool get isPercentageWidth => percentageWidth != null;
  bool get isAvailableWidth => constantWidth == null && percentageWidth == null;
}

/// The types of slots supported
enum SlotIds {
  primaryNavigation,
  secondaryNavigation,
  topNavigation,
  bottomNavigation,
  body,
  secondaryBody,
  tertiaryBody,
}

class AdaptiveLayout extends StatefulWidget {
  AdaptiveLayout({
    super.key,
    SlotLayout? primaryNavigation,
    SlotLayout? secondaryNavigation,
    SlotLayout? topNavigation,
    SlotLayout? bottomNavigation,
    this.body,
    this.secondaryBody,
    this.tertiaryBody,
    this.bodySlotWidths = defaultSlotWidths,
    this.secondaryBodySlotWidths = defaultSlotWidths,
    this.tertiaryBodySlotWidths = defaultSlotWidths,
    this.navigationSlotDefinitions,
    this.includeBorders = false,
    this.borderWidth = 0.0,
    this.borderColor = Colors.black,
  }) {
    if (navigationSlotDefinitions != null) {
      if (navigationSlotDefinitions!.containsKey(SlotIds.primaryNavigation) &&
          primaryNavigation == null) {
        this.primaryNavigation =
            navigationSlotDefinitions![SlotIds.primaryNavigation];
      } else {
        this.primaryNavigation = primaryNavigation;
      }

      if (navigationSlotDefinitions!.containsKey(SlotIds.secondaryNavigation) &&
          secondaryNavigation == null) {
        this.secondaryNavigation =
            navigationSlotDefinitions![SlotIds.secondaryNavigation];
      } else {
        this.secondaryNavigation = secondaryNavigation;
      }

      if (navigationSlotDefinitions!.containsKey(SlotIds.topNavigation) &&
          topNavigation == null) {
        this.topNavigation = navigationSlotDefinitions![SlotIds.topNavigation];
      } else {
        this.topNavigation = topNavigation;
      }

      if (navigationSlotDefinitions!.containsKey(SlotIds.bottomNavigation) &&
          bottomNavigation == null) {
        this.bottomNavigation =
            navigationSlotDefinitions![SlotIds.bottomNavigation];
      } else {
        this.bottomNavigation = bottomNavigation;
      }
    }
  }

  static const Map<int, SlotWidthDefinition> defaultSlotWidths = {
    1: SlotWidthDefinition(),
    2: SlotWidthDefinition(),
    3: SlotWidthDefinition(),
  };

  final Map<SlotIds, SlotLayout?>? navigationSlotDefinitions;

  final Map<int, SlotWidthDefinition> bodySlotWidths;
  final Map<int, SlotWidthDefinition> secondaryBodySlotWidths;
  final Map<int, SlotWidthDefinition> tertiaryBodySlotWidths;

  late final SlotLayout? primaryNavigation;
  late final SlotLayout? secondaryNavigation;
  late final SlotLayout? topNavigation;
  late final SlotLayout? bottomNavigation;

  final SlotLayout? body;
  final SlotLayout? secondaryBody;
  final SlotLayout? tertiaryBody;

  final bool includeBorders;
  final double borderWidth;
  final Color borderColor;

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout>
    with TickerProviderStateMixin {
  late Map<String, SlotLayoutConfig?> chosenWidgets =
      <String, SlotLayoutConfig?>{};
  Map<String, Size?> slotSizes = <String, Size?>{};

  @override
  Widget build(BuildContext context) {
    final Map<String, SlotLayout?> slots = <String, SlotLayout?>{
      SlotIds.primaryNavigation.name: widget.primaryNavigation,
      SlotIds.secondaryNavigation.name: widget.secondaryNavigation,
      SlotIds.topNavigation.name: widget.topNavigation,
      SlotIds.bottomNavigation.name: widget.bottomNavigation,
      SlotIds.body.name: widget.body,
      SlotIds.secondaryBody.name: widget.secondaryBody,
      SlotIds.tertiaryBody.name: widget.tertiaryBody,
    };
    chosenWidgets = <String, SlotLayoutConfig?>{};

    slots.forEach((String key, SlotLayout? value) {
      // slots.update(
      //   key,
      //   (SlotLayout? val) => val,
      //   ifAbsent: () => value,
      // );
      chosenWidgets.update(
        key,
        (SlotLayoutConfig? val) => val,
        ifAbsent: () => SlotLayout.pickWidget(
            context, value?.config ?? <Breakpoint, SlotLayoutConfig?>{}),
      );
    });
    final List<Widget> entries = slots.entries
        .map((MapEntry<String, SlotLayout?> entry) {
          if (entry.value != null) {
            return LayoutId(
                id: entry.key, child: entry.value ?? const SizedBox());
          }
        })
        .whereType<Widget>()
        .toList();

    if (widget.includeBorders) {
      entries.add(LayoutId(
          id: 'border1',
          child: VerticalDivider(
            thickness: widget.borderWidth,
            color: widget.borderColor,
          )));
      entries.add(LayoutId(
          id: 'border2',
          child: VerticalDivider(
            thickness: widget.borderWidth,
            color: widget.borderColor,
          )));
    }

    return CustomMultiChildLayout(
      delegate: AdaptiveLayoutDelegate(
        borderWidth: widget.borderWidth,
        slots: slots,
        chosenWidgets: chosenWidgets,
        textDirectionLTR: Directionality.of(context) == TextDirection.ltr,
        originalBodySlotWidths: widget.bodySlotWidths,
        originalSecondaryBodySlotWidths: widget.secondaryBodySlotWidths,
        originalTertiaryBodySlotWidths: widget.tertiaryBodySlotWidths,
      ),
      children: entries,
    );
  }
}

/// The delegate responsible for laying out the slots in their correct
/// positions.
class AdaptiveLayoutDelegate extends MultiChildLayoutDelegate {
  AdaptiveLayoutDelegate({
    this.borderWidth = 0.0,
    required this.slots,
    required this.chosenWidgets,
    required this.textDirectionLTR,
    required this.originalBodySlotWidths,
    required this.originalSecondaryBodySlotWidths,
    required this.originalTertiaryBodySlotWidths,
  });

  late Map<int, SlotWidthDefinition> bodySlotWidths;
  late Map<int, SlotWidthDefinition> secondaryBodySlotWidths;
  late Map<int, SlotWidthDefinition> tertiaryBodySlotWidths;
  final Map<int, SlotWidthDefinition> originalBodySlotWidths;
  final Map<int, SlotWidthDefinition> originalSecondaryBodySlotWidths;
  final Map<int, SlotWidthDefinition> originalTertiaryBodySlotWidths;
  final Map<String, SlotLayout?> slots;
  final Map<String, SlotLayoutConfig?> chosenWidgets;
  final bool textDirectionLTR;
  final double borderWidth;

  @override
  void performLayout(Size size) {
    bodySlotWidths = Map.from(originalBodySlotWidths);
    secondaryBodySlotWidths = Map.from(originalSecondaryBodySlotWidths);
    tertiaryBodySlotWidths = Map.from(originalTertiaryBodySlotWidths);

    double leftMargin = 0;
    double topMargin = 0;
    double rightMargin = 0;
    double bottomMargin = 0;

    // Layout top navigation slot
    topMargin += _layoutTopNavigation(size);
    // Layout bottom navigation slot
    bottomMargin += _layoutBottomNavigation(size);
    // Layout primary navigation slot
    var width = _layoutPrimaryNavigation(size, leftMargin, topMargin);
    if (textDirectionLTR) {
      leftMargin += width;
    } else {
      rightMargin += width;
    }
    // Layout secondary navigation slot
    width = _layoutSecondaryNavigation(size, topMargin);
    if (textDirectionLTR) {
      rightMargin += width;
    } else {
      leftMargin += width;
    }

    var remainingWidth = size.width - rightMargin - leftMargin;
    final remainingHeight = size.height - bottomMargin - topMargin;

    // Determine the layouts for the body, secondaryBody and tertiaryBody
    // slots

    final activeSlots = _activeSlots;
    final numActiveSlots = activeSlots.length;

    double usedBorderWidth = 0.0;
    if (numActiveSlots == 2) {
      usedBorderWidth += borderWidth;
    } else if (numActiveSlots == 3) {
      usedBorderWidth += (2 * borderWidth);
    }

    remainingWidth -= usedBorderWidth;

    final totalConstantWidth = _constantActiveWidth;

    // Check if there is enough space available to accomodate the constant
    // width definitions. If there is not enough space for all of the constant
    // width, then there will no constant width slots; all will be converted
    // to flexible width slots.
    if (totalConstantWidth > remainingWidth) {
      _adjustConstantWidthToFlexibleWidth(numActiveSlots);
    } else {
      remainingWidth -= totalConstantWidth;
    }

    final totalPercentage = _percentageActive;
    final totalFlexibleWidth =
        remainingWidth - (remainingWidth * totalPercentage);

    var currentBodySize = Size.zero;
    var currentSBodySize = Size.zero;
    var currentTBodySize = Size.zero;

    // Layout of the body slot
    if (_bodySlotDefined) {
      if (_bodySlotActive) {
        currentBodySize = _layoutSlotAccordingToDefinition(
            SlotIds.body,
            numActiveSlots,
            remainingHeight,
            remainingWidth,
            totalFlexibleWidth);
      } else {
        _layoutSlot(SlotIds.body, size, isTight: false);
      }
    }

    // Layout the secondary body slot
    if (_secondaryBodySlotDefined) {
      if (_secondaryBodySlotActive) {
        currentSBodySize = _layoutSlotAccordingToDefinition(
            SlotIds.secondaryBody,
            numActiveSlots,
            remainingHeight,
            remainingWidth,
            totalFlexibleWidth);
      } else {
        _layoutSlot(SlotIds.secondaryBody, size, isTight: false);
      }
    }

    // Layout the tertiary body slot
    if (_tertiaryBodySlotDefined) {
      if (_tertiaryBodySlotActive) {
        currentTBodySize = _layoutSlotAccordingToDefinition(
            SlotIds.tertiaryBody,
            numActiveSlots,
            remainingHeight,
            remainingWidth,
            totalFlexibleWidth);
      } else {
        _layoutSlot(SlotIds.tertiaryBody, size, isTight: false);
      }
    }

    var hasBorder1 = hasChild('border1') && numActiveSlots >= 2;
    var hasBorder2 = hasChild('border2') && numActiveSlots == 3;

    if (hasChild('border1')) {
      if (numActiveSlots >= 2) {
        layoutChild('border1',
            BoxConstraints.tight(Size(borderWidth, remainingHeight)));
      } else {
        layoutChild('border1', BoxConstraints.loose(Size.zero));
      }
    }
    if (hasChild('border2')) {
      if (numActiveSlots == 3) {
        layoutChild('border2',
            BoxConstraints.tight(Size(borderWidth, remainingHeight)));
      } else {
        layoutChild('border2', BoxConstraints.loose(Size.zero));
      }
    }

    // Position the body, secondaryBody and tertiaryBody slots

    var positionedBorder1 = false;
    var positionedBorder2 = false;

    if (_bodySlotActive) {
      positionChild(
          SlotIds.body.name,
          Offset(
              textDirectionLTR
                  ? leftMargin
                  : leftMargin +
                      currentTBodySize.width +
                      currentSBodySize.width +
                      (hasBorder1 ? borderWidth : 0.0) +
                      (hasBorder2 ? borderWidth : 0.0),
              topMargin));
    }

    if (hasBorder1 && !positionedBorder1) {
      positionChild(
          'border1',
          Offset(
              textDirectionLTR
                  ? leftMargin + currentBodySize.width
                  : leftMargin +
                      currentTBodySize.width +
                      currentSBodySize.width +
                      (hasBorder2 ? borderWidth : 0.0),
              topMargin));
      positionedBorder1 = true;
    }

    if (_secondaryBodySlotActive) {
      positionChild(
          SlotIds.secondaryBody.name,
          Offset(
              textDirectionLTR
                  ? leftMargin +
                      currentBodySize.width +
                      (positionedBorder1 ? borderWidth : 0.0)
                  : leftMargin +
                      currentTBodySize.width +
                      (hasBorder2 ? borderWidth : 0.0),
              topMargin));
    }

    if (hasBorder1 && !positionedBorder1) {
      positionChild(
          'border1',
          Offset(
              textDirectionLTR
                  ? leftMargin + currentBodySize.width + currentSBodySize.width
                  : leftMargin + currentTBodySize.width,
              topMargin));
      positionedBorder1 = true;
    } else if (hasBorder2 && !positionedBorder2) {
      positionChild(
          'border2',
          Offset(
              textDirectionLTR
                  ? leftMargin +
                      currentBodySize.width +
                      borderWidth +
                      currentSBodySize.width
                  : leftMargin + currentTBodySize.width,
              topMargin));
      positionedBorder2 = true;
    }

    if (_tertiaryBodySlotActive) {
      positionChild(
          SlotIds.tertiaryBody.name,
          Offset(
              textDirectionLTR
                  ? leftMargin +
                      currentBodySize.width +
                      currentSBodySize.width +
                      (positionedBorder1 ? borderWidth : 0.0) +
                      (positionedBorder2 ? borderWidth : 0.0)
                  : leftMargin,
              topMargin));
    }
  }

  Size _layoutSlotAccordingToDefinition(
    SlotIds slot,
    int numActiveSlots,
    double remainingHeight,
    double remainingWidth,
    double totalFlexibleWidth,
  ) {
    var size = Size.zero;
    final slotWidthDefinition =
        _getWidthDefinitionForSlot(slot, numActiveSlots);
    if (slotWidthDefinition != null) {
      if (slotWidthDefinition.isConstantWidth) {
        size = _layoutSlot(
            slot, Size(slotWidthDefinition.constantWidth!, remainingHeight));
      } else if (slotWidthDefinition.isPercentageWidth) {
        size = _layoutSlot(
            slot,
            Size(slotWidthDefinition.percentageWidth! * remainingWidth,
                remainingHeight));
      } else {
        size = _layoutSlot(slot,
            Size(totalFlexibleWidth / _numFlexibleWidthSlots, remainingHeight));
      }
    }
    return size;
  }

  /// Helper method to layout the contents of a slot
  Size _layoutSlot(SlotIds slot, Size size, {bool isTight = true}) {
    final constraints =
        isTight ? BoxConstraints.tight(size) : BoxConstraints.loose(size);
    return layoutChild(slot.name, constraints);
  }

  /// Helper method to layout the top navigation slot. Returns the height
  /// of the top navigation widget, if there is one. If there is no top
  /// navigation widget, then a height of 0.0 is returned.
  double _layoutTopNavigation(Size size) {
    var height = 0.0;
    if (_topNavigationDefined) {
      final Size childSize = layoutChild(
        SlotIds.topNavigation.name,
        BoxConstraints.loose(size),
      );
      positionChild(SlotIds.topNavigation.name, Offset.zero);
      height = childSize.height;
    }
    return height;
  }

  /// Helper method to layout the bottom navigation slot. Returns the height
  /// of the bottom navigation widget, if there is one. If there is no bottom
  /// navigation widget, then a height of 0.0 is returned.
  double _layoutBottomNavigation(Size size) {
    var height = 0.0;
    if (_bottomNavigationDefined) {
      final Size childSize = layoutChild(
        SlotIds.bottomNavigation.name,
        BoxConstraints.loose(size),
      );
      positionChild(
        SlotIds.bottomNavigation.name,
        Offset(0, size.height - childSize.height),
      );
      height = childSize.height;
    }
    return height;
  }

  /// Helper method to layout the primary navigation slot. Returns the width
  /// of the primary navigation widget, if there is one. If there is no primary
  /// navigation widget, then a width of 0.0 is returned.
  double _layoutPrimaryNavigation(
      Size size, double leftMargin, double topMargin) {
    var width = 0.0;
    if (_primaryNavigationDefined) {
      final Size childSize = layoutChild(
        SlotIds.primaryNavigation.name,
        BoxConstraints.loose(size),
      );
      if (textDirectionLTR) {
        positionChild(
          SlotIds.primaryNavigation.name,
          Offset(leftMargin, topMargin),
        );
        width = childSize.width;
      } else {
        positionChild(
          SlotIds.primaryNavigation.name,
          Offset(size.width - childSize.width, topMargin),
        );
        width = childSize.width;
      }
    }
    return width;
  }

  /// Helper method to layout the secondary navigation slot. Returns the width
  /// of the secondary navigation widget, if there is one. If there is no
  /// secondary navigation widget, then a width of 0.0 is returned.
  double _layoutSecondaryNavigation(Size size, double topMargin) {
    var width = 0.0;
    if (_secondaryNavigationDefined) {
      final Size childSize = layoutChild(
        SlotIds.secondaryNavigation.name,
        BoxConstraints.loose(size),
      );
      if (textDirectionLTR) {
        positionChild(
          SlotIds.secondaryNavigation.name,
          Offset(size.width - childSize.width, topMargin),
        );
        width = childSize.width;
      } else {
        positionChild(SlotIds.secondaryNavigation.name, Offset(0, topMargin));
        width = childSize.width;
      }
    }
    return width;
  }

  /// Helper property to indicate if the top navigation slot is defined
  bool get _topNavigationDefined => hasChild(SlotIds.topNavigation.name);

  /// Helper property to indicate if the bottom navigation slot is defined
  bool get _bottomNavigationDefined => hasChild(SlotIds.bottomNavigation.name);

  /// Helper property to indicate if the primary navigation slot is defined
  bool get _primaryNavigationDefined =>
      hasChild(SlotIds.primaryNavigation.name);

  /// Helper property to indicate if the secondary navigation slot is defined
  bool get _secondaryNavigationDefined =>
      hasChild(SlotIds.secondaryNavigation.name);

  /// Helper property to indicate if the body slot is defined
  bool get _bodySlotDefined => hasChild(SlotIds.body.name);

  /// Helper property to indicate if the secondary body slot is defined
  bool get _secondaryBodySlotDefined => hasChild(SlotIds.secondaryBody.name);

  /// Helper property to indicate if the tertiary body slot is defined
  bool get _tertiaryBodySlotDefined => hasChild(SlotIds.tertiaryBody.name);

  /// Helper property to indicate if the body slot is inactive
  bool get _bodySlotInactive =>
      chosenWidgets[SlotIds.body.name] == null ||
      chosenWidgets[SlotIds.body.name]!.builder == null;
  bool get _bodySlotActive => !_bodySlotInactive;

  /// Helper property to indicate if the secondary body slot is inactive
  bool get _secondaryBodySlotInactive =>
      chosenWidgets[SlotIds.secondaryBody.name] == null ||
      chosenWidgets[SlotIds.secondaryBody.name]!.builder == null;
  bool get _secondaryBodySlotActive => !_secondaryBodySlotInactive;

  /// Helper property to indicate if the tertiary body slot is inactive
  bool get _tertiaryBodySlotInactive =>
      chosenWidgets[SlotIds.tertiaryBody.name] == null ||
      chosenWidgets[SlotIds.tertiaryBody.name]!.builder == null;
  bool get _tertiaryBodySlotActive => !_tertiaryBodySlotInactive;

  /// Helper property to get collection of all active slots
  List<SlotIds> get _activeSlots {
    final slots = <SlotIds>[];
    if (_bodySlotActive) {
      slots.add(SlotIds.body);
    }

    if (_secondaryBodySlotActive) {
      slots.add(SlotIds.secondaryBody);
    }

    if (_tertiaryBodySlotActive) {
      slots.add(SlotIds.tertiaryBody);
    }
    return slots;
  }

  /// Helper property to get the number of slots that are not constants or percentage width
  int get _numFlexibleWidthSlots {
    var numSlots = 0;
    final activeSlots = _activeSlots;
    if (_bodySlotActive) {
      if (_isFlexibleWidthSlot(bodySlotWidths, activeSlots.length)) {
        numSlots++;
      }
    }
    if (_secondaryBodySlotActive) {
      if (_isFlexibleWidthSlot(secondaryBodySlotWidths, activeSlots.length)) {
        numSlots++;
      }
    }
    if (_tertiaryBodySlotActive) {
      if (_isFlexibleWidthSlot(tertiaryBodySlotWidths, activeSlots.length)) {
        numSlots++;
      }
    }
    return numSlots;
  }

  /// Helper property to get the total constant width of active slots
  double get _constantActiveWidth {
    var width = 0.0;

    final activeSlots = _activeSlots;
    if (_bodySlotActive) {
      width += _getConstantWidthForSlot(bodySlotWidths, activeSlots.length);
    }
    if (_secondaryBodySlotActive) {
      width +=
          _getConstantWidthForSlot(secondaryBodySlotWidths, activeSlots.length);
    }
    if (_tertiaryBodySlotActive) {
      width +=
          _getConstantWidthForSlot(tertiaryBodySlotWidths, activeSlots.length);
    }
    return width;
  }

  /// Helper property to get the total percentage width of active slots
  double get _percentageActive {
    var percentage = 0.0;

    final activeSlots = _activeSlots;
    if (_bodySlotActive) {
      percentage += _getPercentageForSlot(bodySlotWidths, activeSlots.length);
    }
    if (_secondaryBodySlotActive) {
      percentage +=
          _getPercentageForSlot(secondaryBodySlotWidths, activeSlots.length);
    }
    if (_tertiaryBodySlotActive) {
      percentage +=
          _getPercentageForSlot(tertiaryBodySlotWidths, activeSlots.length);
    }
    return percentage;
  }

  bool _isFlexibleWidthSlot(
      Map<int, SlotWidthDefinition> slotWidths, int numActiveSlots) {
    var isFlexibleWidthSlot = false;
    if (slotWidths.containsKey(numActiveSlots)) {
      final widthDefinition = slotWidths[numActiveSlots]!;
      if (widthDefinition.isAvailableWidth) {
        isFlexibleWidthSlot = true;
      }
    }
    return isFlexibleWidthSlot;
  }

  double _getConstantWidthForSlot(
      Map<int, SlotWidthDefinition> slotWidths, int numActiveSlots) {
    var width = 0.0;
    if (slotWidths.containsKey(numActiveSlots)) {
      final widthDefinition = slotWidths[numActiveSlots]!;
      if (widthDefinition.isConstantWidth) {
        width = widthDefinition.constantWidth!;
      }
    }
    return width;
  }

  double _getPercentageForSlot(
      Map<int, SlotWidthDefinition> slotWidths, int numActiveSlots) {
    var percentage = 0.0;
    if (slotWidths.containsKey(numActiveSlots)) {
      final widthDefinition = slotWidths[numActiveSlots]!;
      if (widthDefinition.isPercentageWidth) {
        percentage = widthDefinition.percentageWidth!;
      }
    }
    return percentage;
  }

  SlotWidthDefinition? _getWidthDefinitionForSlot(
      SlotIds slot, int numActiveSlots) {
    SlotWidthDefinition? slotWidthDefinition;
    switch (slot) {
      case SlotIds.body:
        if (bodySlotWidths.containsKey(numActiveSlots)) {
          slotWidthDefinition = bodySlotWidths[numActiveSlots];
        }
        break;
      case SlotIds.secondaryBody:
        if (secondaryBodySlotWidths.containsKey(numActiveSlots)) {
          slotWidthDefinition = secondaryBodySlotWidths[numActiveSlots];
        }
        break;
      case SlotIds.tertiaryBody:
        if (tertiaryBodySlotWidths.containsKey(numActiveSlots)) {
          slotWidthDefinition = tertiaryBodySlotWidths[numActiveSlots];
        }
        break;
      default:
        slotWidthDefinition = null;
    }
    return slotWidthDefinition;
  }

  void _adjustConstantWidthToFlexibleWidth(int numActiveSlots) {
    if (_bodySlotActive) {
      final slotWidth = bodySlotWidths[numActiveSlots];
      if (slotWidth != null && slotWidth.isConstantWidth) {
        bodySlotWidths[numActiveSlots] = const SlotWidthDefinition();
      }
    }
    if (_secondaryBodySlotActive) {
      final slotWidth = secondaryBodySlotWidths[numActiveSlots];
      if (slotWidth != null && slotWidth.isConstantWidth) {
        secondaryBodySlotWidths[numActiveSlots] = const SlotWidthDefinition();
      }
    }
    if (_bodySlotActive) {
      final slotWidth = tertiaryBodySlotWidths[numActiveSlots];
      if (slotWidth != null && slotWidth.isConstantWidth) {
        tertiaryBodySlotWidths[numActiveSlots] = const SlotWidthDefinition();
      }
    }
  }

  @override
  bool shouldRelayout(AdaptiveLayoutDelegate oldDelegate) {
    return oldDelegate.slots != slots;
  }
}
