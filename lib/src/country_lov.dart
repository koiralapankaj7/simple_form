import 'package:flutter/material.dart';
import 'package:simple_form/src/country_repository.dart';
import 'package:simple_utils/simple_utils.dart';

///
class CountryLov extends StatefulWidget {
  ///
  const CountryLov({super.key, this.repository});

  ///
  final CountryRepository? repository;

  ///
  static Future<Country?> open(
    BuildContext context, {
    CountryRepository? repository,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return CountryLov(repository: repository);
      },
    );
  }

  @override
  State<CountryLov> createState() => _CountryLovState();
}

class _CountryLovState extends State<CountryLov> {
  late final _repo = widget.repository ?? CountryRepository.instance;
  late final _debouncer = Debouncer(const Duration(milliseconds: 200));

  @override
  void dispose() {
    _debouncer.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      _debouncer.call(() {
                        _repo.search(value);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Ink(
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.surface,
                    shape: const CircleBorder(),
                  ),
                  child: IconButton(
                    onPressed: Navigator.of(context).pop,
                    constraints: BoxConstraints.tight(
                      const Size.square(40),
                    ),
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(),

          // List
          Expanded(
            child: ListenableBuilder(
              listenable: _repo,
              builder: (context, child) {
                final countries = _repo.countries;
                if (_repo.countries.isEmpty) {
                  return const Center(
                    child: Text('No Data'),
                  );
                }

                return ListView.builder(
                  itemCount: countries.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _CountryTile(
                      country: countries.elementAt(index),
                      background: theme.colorScheme.surface
                          .withAlpha(index.isOdd ? 100 : 150),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.background,
  });

  final Country country;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: background,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(country),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(country.unicodeFlag),
              const SizedBox(width: 16),
              Expanded(child: Text(country.name)),
            ],
          ),
        ),
      ),
    );
  }
}
