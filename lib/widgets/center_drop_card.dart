import 'package:flutter/material.dart';

class CenterDropCard extends StatelessWidget {
  /// Eski kullanım bozulmasın diye default verdik.
  final List<String> droppedAddresses;

  /// Adres drop edilince çalışır (zorunlu).
  final void Function(String) onDropAddress;

  /// HomePage’in mevcut UI’si için opsiyonel alanlar
  final String? title;
  final String? dropdownValue;
  final List<String>? dropdownItems;
  final ValueChanged<String>? onDropdownChanged;
  final String? helperText;

  const CenterDropCard({
    super.key,
    this.droppedAddresses = const [],
    required this.onDropAddress,
    this.title,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        // details.data drop edilen string
        onDropAddress(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 160,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE0F2E5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? Colors.green : Colors.black12,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (dropdownValue != null &&
                  dropdownItems != null &&
                  onDropdownChanged != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAF7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      isExpanded: true,
                      items: dropdownItems!
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) onDropdownChanged!(v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (helperText != null) ...[
                Text(
                  helperText!,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 10),
              ],

              Expanded(
                child: Center(
                  child: droppedAddresses.isEmpty
                      ? const Text(
                          'Adresleri buraya sürükle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Seçilen Adresler:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            ...droppedAddresses.map(
                              (addr) => Text(
                                '• $addr',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
