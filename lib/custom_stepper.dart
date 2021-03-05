import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum StepState {
  /// A step that displays its index in its circle.
  indexed,

  /// A step that displays a pencil icon in its circle.
  editing,

  /// A step that displays a tick icon in its circle.
  complete,

  /// A step that is disabled and does not to react to taps.
  disabled,

  /// A step that is currently having an error. e.g. the user has submitted wrong
  /// input.
  error,
}

const TextStyle _kStepStyle = TextStyle(
    fontSize: 12.0, color: Colors.white, decoration: TextDecoration.none);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const Color _kDisabledLight = Colors.black38;
const Color _kDisabledDark = Colors.white38;
const double _kStepSize = 50.0;
const double _kStepCircleContentSize = 20.0;
const double _kTriangleHeight =
    _kStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

/// A material step used in [Stepper]. The step can have a title and subtitle,
/// an icon within its circle, some content and a state that governs its
/// styling.
///
/// See also:
///
///  * [Stepper]
///  * <https://material.io/archive/guidelines/components/steppers.html>
@immutable
class Step {
  /// Creates a step for a [Stepper].
  ///
  /// The [title], [content], and [state] arguments must not be null.
  const Step({
    required this.title,
    this.subtitle,
    required this.content,
    this.state = StepState.indexed,
    this.isActive = false,
  });

  /// The title of the step that typically describes it.
  final Widget title;

  /// The subtitle of the step that appears below the title and has a smaller
  /// font size. It typically gives more details that complement the title.
  ///
  /// If null, the subtitle is not shown.
  final Widget? subtitle;

  /// The content of the step that appears below the [title] and [subtitle].
  ///
  /// Below the content, every step has a 'continue' and 'cancel' button.
  final Widget content;

  /// The state of the step which determines the styling of its components
  /// and whether steps are interactive.
  final StepState state;

  /// Whether or not the step is active. The flag only influences styling.
  final bool isActive;
}

class CustomStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  const CustomStepper({
    Key? key,
    required this.steps,
    this.physics,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.onStepMoveUp,
    this.onStepMoveDown,
    this.onStepRename,
    this.onStepDelete,
    this.onStepDropAccepted,
    this.controlsBuilder,
  }) : super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<Step> steps;

  /// How the stepper's scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to
  /// animate after the user stops dragging the scroll view.
  ///
  /// If the stepper is contained within another scrollable it
  /// can be helpful to set this property to [ClampingScrollPhysics].
  final ScrollPhysics? physics;

  /// The index into [steps] of the current step whose content is displayed.
  final int? currentStep;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int>? onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback? onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback? onStepCancel;

  /// !NEW!
  ///
  /// The callback called when the step menu item move up is tapped.
  /// If null the menu item won't be visible.
  final ValueSetter<int>? onStepMoveUp;

  /// !NEW!
  ///
  /// The callback called when the step menu item move up is tapped.
  /// If null the menu item won't be visible.
  final ValueSetter<int>? onStepMoveDown;

  /// !NEW!
  ///
  /// The callback called when the step menu item rename is tapped.
  /// If null the menu item won't be visible.
  final ValueSetter<int>? onStepRename;

  /// !NEW!
  ///
  /// The callback called when the remove step icon button is tapped.
  /// If null the button won't be visible.
  final ValueSetter<int>? onStepDelete;

  /// !NEW!
  ///
  /// The callback called when user drags and drops step onto another one
  final void Function(int, int)? onStepDropAccepted;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  final ControlsWidgetBuilder? controlsBuilder;

  @override
  _StepperState createState() => _StepperState();
}

class _StepperState extends State<CustomStepper> with TickerProviderStateMixin {
  late List<GlobalKey> _keys;
  final Map<int, StepState> _oldStates = <int, StepState>{};

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    for (int i = 0; i < widget.steps.length; i += 1)
      _oldStates[i] = widget.steps[i].state;
  }

  // Commented out to make removing steps work
  //
  // @override
  // void didUpdateWidget(CustomStepper oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   assert(widget.steps.length == oldWidget.steps.length);

  //   for (int i = 0; i < oldWidget.steps.length; i += 1)
  //     _oldStates[i] = oldWidget.steps[i].state;
  // }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index, bool oldState) {
    final StepState state =
        oldState ? _oldStates[index]! : widget.steps[index].state;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    switch (state) {
      case StepState.indexed:
      case StepState.disabled:
        return Text(
          '${index + 1}',
          style: isDarkActive
              ? _kStepStyle.copyWith(color: Colors.black87, fontSize: _kStepCircleContentSize)
              : _kStepStyle.copyWith(fontSize: _kStepCircleContentSize),
        );
      case StepState.editing:
        return Icon(
          Icons.edit,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: _kStepCircleContentSize,
        );
      case StepState.complete:
        return Icon(
          Icons.check,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: _kStepCircleContentSize,
        );
      case StepState.error:
        return const Text('!', style: _kStepStyle);
    }
  }

  Color _circleColor(int index) {
    final ThemeData themeData = Theme.of(context);
    if (!_isDark()) {
      return widget.steps[index].isActive
          ? themeData.primaryColor
          : Colors.black38;
    } else {
      return widget.steps[index].isActive
          ? themeData.accentColor
          : themeData.backgroundColor;
    }
  }

  Widget _buildCircle(int index, bool oldState) {
    return Draggable(
      data: index,
      axis: Axis.vertical,
      childWhenDragging: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: _kStepSize,
        height: _kStepSize,
        child: AnimatedContainer(
          curve: Curves.fastOutSlowIn,
          duration: kThemeAnimationDuration,
          decoration: BoxDecoration(
            color: _circleColor(index).withAlpha(80),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _buildCircleChild(index,
                oldState && widget.steps[index].state == StepState.error),
          ),
        ),
      ),
      feedback: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        width: _kStepSize,
        height: _kStepSize,
        decoration:
            BoxDecoration(color: _circleColor(index), shape: BoxShape.circle),
        child: Center(
          child: _buildCircleChild(
              index, oldState && widget.steps[index].state == StepState.error),
        ),
      ),
      child: Stack(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: _kStepSize,
          height: _kStepSize,
          child: AnimatedContainer(
            curve: Curves.fastOutSlowIn,
            duration: kThemeAnimationDuration,
            decoration: BoxDecoration(
              color: hoveringOver == index ? Colors.green : _circleColor(index),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildCircleChild(index,
                  oldState && widget.steps[index].state == StepState.error),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          width: _kStepSize,
          height: _kStepSize,
          child: DragTarget(
            builder: (context, List<int?> candidateData, rejectedData) {
              return Container();
            },
            onWillAccept: (data) {
              setState(() {
                hoveringOver = index;
              });
              return true;
            },
            onLeave: (data) {
              setState(() {
                hoveringOver = null;
              });
            },
            onAccept: (data) {
              var oldIndex = int.tryParse(data.toString());

              if (widget.onStepDropAccepted != null && oldIndex != null) {
                widget.onStepDropAccepted!(oldIndex, index);
                hoveringOver = null;
              }
            },
          ),
        ),
      ]),
    );
  }

  int? hoveringOver;

  Widget _buildTriangle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: Center(
        child: SizedBox(
          width: _kStepSize,
          height:
              _kTriangleHeight, // Height of 24dp-long-sided equilateral triangle.
          child: CustomPaint(
            painter: _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: Align(
              alignment: const Alignment(
                  0.0, 0.8), // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(index,
                  oldState && widget.steps[index].state != StepState.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].state == StepState.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != StepState.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls() {
    if (widget.controlsBuilder != null)
      return widget.controlsBuilder!(context,
          onStepContinue: widget.onStepContinue,
          onStepCancel: widget.onStepCancel);

    final Color cancelColor;
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    const OutlinedBorder buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)));
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16.0);

    return Container(
      //margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 0.0), // was 48
        child: Row(
          // The Material spec no longer includes a Stepper widget. The continue
          // and cancel button styles have been configured to match the original
          // version of this widget.
          children: <Widget>[
            // TextButton(
            //   onPressed: widget.onStepContinue,
            //   style: ButtonStyle(
            //     foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            //         (Set<MaterialState> states) {
            //       return states.contains(MaterialState.disabled)
            //           ? null
            //           : (_isDark()
            //               ? colorScheme.onSurface
            //               : colorScheme.onPrimary);
            //     }),
            //     backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            //         (Set<MaterialState> states) {
            //       return _isDark() || states.contains(MaterialState.disabled)
            //           ? null
            //           : colorScheme.primary;
            //     }),
            //     padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            //         buttonPadding),
            //     shape: MaterialStateProperty.all<OutlinedBorder>(buttonShape),
            //   ),
            //   child: Text(localizations.continueButtonLabel),
            // ),
            // Container(
            //   margin: const EdgeInsetsDirectional.only(start: 8.0),
            //   child: TextButton(
            //     onPressed: widget.onStepCancel,
            //     style: TextButton.styleFrom(
            //       primary: cancelColor,
            //       padding: buttonPadding,
            //       shape: buttonShape,
            //     ),
            //     child: Text(localizations.cancelButtonLabel),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.bodyText1!;
      case StepState.disabled:
        return textTheme.bodyText1!
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.bodyText1!
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
  }

  TextStyle _subtitleStyle(int index) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case StepState.indexed:
      case StepState.editing:
      case StepState.complete:
        return textTheme.caption!;
      case StepState.disabled:
        return textTheme.caption!
            .copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case StepState.error:
        return textTheme.caption!
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
  }

  Widget _buildHeaderText(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedDefaultTextStyle(
          style: _titleStyle(index),
          duration: kThemeAnimationDuration,
          curve: Curves.fastOutSlowIn,
          child: widget.steps[index].title,
        ),
        if (widget.steps[index].subtitle != null)
          Container(
            margin: const EdgeInsets.only(top: 2.0),
            child: AnimatedDefaultTextStyle(
              style: _subtitleStyle(index),
              duration: kThemeAnimationDuration,
              curve: Curves.fastOutSlowIn,
              child: widget.steps[index].subtitle!,
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: _buildHeaderText(index),
          )),
          if (_isCurrent(index))
            PopupMenuButton<ValueSetter<int>>(
              itemBuilder: (BuildContext context) => [
                if (widget.onStepMoveUp != null && !_isFirst(index))
                  PopupMenuItem<ValueSetter<int>>(
                    child: Text("Move Up"),
                    value: widget.onStepMoveUp,
                  ),
                if (widget.onStepMoveDown != null && !_isLast(index))
                  PopupMenuItem<ValueSetter<int>>(
                    child: Text("Move Down"),
                    value: widget.onStepMoveDown,
                  ),
                if (widget.onStepRename != null)
                  PopupMenuItem<ValueSetter<int>>(
                    child: Text("Rename"),
                    value: widget.onStepRename,
                  )
              ],
              onSelected: (ValueSetter<int> callback) {
                callback(index);
              },
            ),
          if (_isCurrent(index) && widget.onStepDelete != null)
            IconButton(
                icon: Icon(Icons.close, color: Colors.red[600]),
                onPressed: () {
                  widget.onStepDelete!(index);
                })
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: _kStepSize,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: <Widget>[
        for (int i = 0; i < widget.steps.length; i += 1)
          Column(
            key: _keys[i],
            children: <Widget>[
              InkWell(
                onTap: widget.steps[i].state != StepState.disabled
                    ? () {
                        // In the vertical case we need to scroll to the newly tapped
                        // step.
                        Scrollable.ensureVisible(
                          _keys[i].currentContext!,
                          curve: Curves.fastOutSlowIn,
                          duration: kThemeAnimationDuration,
                        );

                        if (widget.onStepTapped != null)
                          widget.onStepTapped!(i);
                      }
                    : null,
                canRequestFocus: widget.steps[i].state != StepState.disabled,
                child: _buildVerticalHeader(i),
              ),
              _buildVerticalBody(i),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.findAncestorWidgetOfExactType<Stepper>() != null)
        throw FlutterError('Steppers must not be nested.\n'
            'The material specification advises that one should avoid embedding '
            'steppers within steppers. '
            'https://material.io/archive/guidelines/components/steppers.html#steppers-usage');
      return true;
    }());

    return _buildVertical();
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    required this.color,
  });

  final Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      Offset(0.0, height),
      Offset(base, height),
      Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color,
    );
  }
}
