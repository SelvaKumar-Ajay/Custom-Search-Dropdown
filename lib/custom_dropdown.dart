import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  const CustomDropdown(
      {super.key, required this.items, required this.itemLabelBuilder});

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  /// Using [OverlayPortalController] to place menu items as Layer
  final OverlayPortalController _overlayCtrlr = OverlayPortalController();

  /// [LayerLink] which is an helper to place DD childs beneath DD
  final _link = LayerLink();

  /// with [GlobalKey] we get the size of button
  final GlobalKey _buttonKey = GlobalKey();
  double? _generalWidth;

  /// Dropdown's open close state identifier
  bool visibleState = false;

  // to control the filter
  final TextEditingController _txtCtrlr = TextEditingController();

  // show items
  List<T> filteredItems = <T>[];

  // METHOD: Ontap of dropdown arrow button actions
  void onTap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        visibleState = !visibleState;
      });
      // Assign value for [_generalWidth]
      final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
      _generalWidth = box?.size.width;

      _overlayCtrlr.toggle();
    });
  }

  // METHOD: on submission [_txtCtrlr] actions
  void submitOnTap(String? val) {
    setState(() {
      /// on submission check for user typed text is existing in [filteredItems]
      bool isAvailSubmit = widget.items.any(
        (element) => element.toString() == val!,
      );

      if (!isAvailSubmit) {
        /// if [!isAvailSubmit] Assign first visible item to [_txtCtrlr.text] or if none empty it.
        _txtCtrlr.text = filteredItems.isNotEmpty
            ? widget.itemLabelBuilder(filteredItems[0])
            : '';
      }
      // reset state
      visibleState = false;
      _generalWidth = context.size?.width;
    });
    // reset overlay
    if (_overlayCtrlr.isShowing) {
      _overlayCtrlr.toggle();
    }
  }

  // METHOD: on Type of Text Field actions
  void Function(String)? onChanged(String? val) {
    // set State & Overlay Visible
    if (!_overlayCtrlr.isShowing) {
      _overlayCtrlr.show();
      visibleState = true;
    }
    // filtering
    final query = val?.toLowerCase();
    final newFiltered = (query == null || query.isEmpty)
        ? widget.items
        : widget.items
            .where((item) => widget
                .itemLabelBuilder(item)
                .toString()
                .toLowerCase()
                .contains(query))
            .toList();
    if (filteredItems != newFiltered) {
      setState(() => filteredItems = newFiltered);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    /// assign intial values to [filteredItems]
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    super.dispose();
    _txtCtrlr.dispose();
    filteredItems.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayCtrlr,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: MenuWidget(
                menuItemLabelBuilder: widget.itemLabelBuilder,
                items: filteredItems,
                width: _generalWidth,
                onItemSelected: (value) {
                  // On selection of an item, reset all
                  FocusScope.of(context).unfocus();
                  _txtCtrlr.text = widget.itemLabelBuilder(value).toString();
                  _overlayCtrlr.hide();
                  setState(() => visibleState = false);
                },
              ),
            ),
          );
        },
        child: ButtonWidget(
          key: _buttonKey,
          onTap: onTap,
          visibleState: visibleState,
          width: _generalWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: _txtCtrlr,
              autofocus: false,
              keyboardType: TextInputType.text,
              onSubmitted: submitOnTap,
              onChanged: onChanged,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final Widget? child;
  final bool visibleState;

  const ButtonWidget({
    super.key,
    this.height = 48,
    this.width,
    this.onTap,
    this.child,
    this.visibleState = false,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12),
        ),
        child: InkWell(
          onTap: () {
            if (widget.onTap == null) return;
            widget.onTap!();
          },
          borderRadius: BorderRadius.circular(10),
          overlayColor: WidgetStatePropertyAll(Colors.pink[100]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: widget.child ?? const SizedBox.shrink(),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedRotation(
                    turns: widget.visibleState ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.black54,
                      size: 30,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuWidget<T> extends StatelessWidget {
  final double? width;
  final double? height;
  final List<T> items;
  final ValueChanged<T>? onItemSelected;
  final String Function(T) menuItemLabelBuilder;

  const MenuWidget({
    super.key,
    this.width,
    this.height,
    required this.items,
    this.onItemSelected,
    required this.menuItemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: BoxConstraints(
        maxHeight: height ?? 200,
      ),
      child: Material(
        child: Ink(
          width: width ?? double.infinity,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1.5,
                color: Colors.black26,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 20,
                offset: Offset(0, 15),
                spreadRadius: -20,
              ),
            ],
          ),
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No items found."),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  cacheExtent: 0.0,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.pink[100]),
                      onTap: () => onItemSelected?.call(item),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(10),
                        child: Text(menuItemLabelBuilder(item)),
                      ),
                    );
                  }),
        ),
      ),
    );
  }
}
