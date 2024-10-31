import 'package:flutter/material.dart';

class DefaultButtonWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasBorder;
  final bool disabled;
  final bool isTitleBold;
  final bool hasPrimaryBorder;
  final Function()? onPressed;
  final IconData? icon;
  final double height;
  final double width;
  final double? borderRadius;
  final double? iconSize;
  final double? titleSize;
  final Color? primaryColor;
  final Color? iconColor;
  final Color? primaryLightColor;
  final Color? colorButton;

  DefaultButtonWidget({
    super.key,
    this.title = '',
    this.subtitle,
    this.hasBorder = false,
    this.disabled = false,
    this.onPressed,
    this.icon,
    this.height = 48.0,
    this.width = double.infinity,
    this.borderRadius,
    this.primaryColor,
    this.iconColor,
    this.primaryLightColor,
    this.iconSize,
    this.titleSize,
    this.isTitleBold = false,
    this.hasPrimaryBorder = false,
    this.colorButton,
  });

  @override
  Widget build(BuildContext context) {
    // if (primaryColor == null) {
    //   primaryColor = shared.primaryColor;
    // }
    // if (primaryLightColor == null) {
    //   primaryLightColor = shared.primaryLightColor;
    // }

    return Material(
      borderRadius: BorderRadius.circular(40),
      color: Colors.green,
      child: Ink(
        decoration: BoxDecoration(
          color: hasBorder
              ? disabled
                  ? primaryLightColor
                  : const Color(0xfff1f1f1)
              : disabled
                  ? primaryLightColor
                  : primaryColor,
          // borderRadius: BorderRadius.circular(Sizes.RADIUS_10),
          // border: Border.all(color: AppColors.white, width: 1.0),
        ),
        child: InkWell(
          splashColor: hasBorder
              ? primaryColor
              : icon != null
                  ? Colors.green
                  : Colors.green,
          highlightColor: hasBorder
              ? primaryColor
              : icon != null
                  ? Colors.transparent
                  : Colors.green,
          onTap: onPressed!,
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 50,
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon != null
                    ? Row(
                        children: [
                          Icon(
                            icon,
                            color: hasBorder
                                ? primaryColor
                                : iconColor ?? Colors.white,
                            size: iconSize,
                          ),
                          title != ''
                              ? const SizedBox(
                                  width: 12,
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const SizedBox(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize ?? 15.0,
                        color: hasBorder
                            ? primaryColor
                            : hasPrimaryBorder
                                ? primaryLightColor
                                : Colors.white,
                        fontWeight: isTitleBold ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle == null
                        ? const SizedBox()
                        : Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: hasBorder ? primaryColor : Colors.white,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
