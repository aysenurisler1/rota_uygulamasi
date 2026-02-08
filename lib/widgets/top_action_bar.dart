import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({
    super.key,
    required this.filterValue,
    required this.filterItems,
    required this.onFilterChanged,
    required this.primaryColor,
    required this.onUploadPressed,
    required this.onCalendarPressed,
  });

  final String filterValue;
  final List<String> filterItems;
  final ValueChanged<String> onFilterChanged;

  final Color primaryColor;
  final VoidCallback onUploadPressed;
  final VoidCallback onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: Filtre Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filterItems.contains(filterValue)
                      ? filterValue
                      : filterItems.first,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more),
                  items: filterItems
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    onFilterChanged(v);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Sağ: Aksiyonlar
          _ActionIconButton(
            tooltip: 'Yükle',
            icon: Icons.upload_file,
            color: primaryColor,
            onPressed: onUploadPressed,
          ),
          const SizedBox(width: 8),
          _ActionIconButton(
            tooltip: 'Takvim',
            icon: Icons.calendar_month,
            color: primaryColor,
            onPressed: onCalendarPressed,
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

//x
