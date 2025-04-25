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
      if (_overlayCtrlr.isShowing) {
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
        _overlayCtrlr.toggle();
      } else {
        // if [_overlayCtrlr.isShowing] is false then no need to an value
        _txtCtrlr.text = "";
      }

      // reset state
      visibleState = false;
      _generalWidth = context.size?.width;
      filteredItems = widget.items;
    });
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
        child: SizedBox(
          width: _generalWidth,
          child: TextField(
            key: _buttonKey,
            controller: _txtCtrlr,
            autofocus: false,
            keyboardType: TextInputType.text,
            onSubmitted: submitOnTap,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              constraints: const BoxConstraints(minHeight: 40, maxHeight: 50),
              contentPadding: const EdgeInsets.all(10),
              suffixIcon: InkWell(
                onTap: () => onTap.call(),
                borderRadius: BorderRadius.circular(10),
                overlayColor: WidgetStatePropertyAll(Colors.pink[100]),
                child: AnimatedRotation(
                  turns: visibleState ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.black54,
                    size: 30,
                  ),
                ),
              ),
              fillColor: Colors.white12,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black.withAlpha(80),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.pink),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
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
