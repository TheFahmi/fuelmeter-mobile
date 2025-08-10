import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class FuelPricesPage extends StatelessWidget {
  const FuelPricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga BBM Terkini'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100, // Space for BottomAppBar + FAB
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bensin Section
                _buildSectionTitle('Bensin (Gasoline)'),
                const SizedBox(height: 12),
                _buildFuelTypeCard([
                  _buildFuelRow('RON', '90', [
                    _buildPriceItem(
                        'assets/logos/pertamina.png', '10.000', 'Pertalite'),
                    _buildPriceItem(
                        'assets/logos/vivo.png', '12.490', 'Revvo90'),
                    _buildPriceItem('assets/logos/bp.png', '-', ''),
                    _buildPriceItem('assets/logos/shell.png', '-', ''),
                  ]),
                  const Divider(height: 1),
                  _buildFuelRow('', '92', [
                    _buildPriceItem(
                        'assets/logos/pertamina.png', '12.200', 'Pertamax'),
                    _buildPriceItem(
                        'assets/logos/vivo.png', '12.580', 'Revvo92'),
                    _buildPriceItem('assets/logos/bp.png', '12.550', 'BP 92'),
                    _buildPriceItem(
                        'assets/logos/shell.png', '12.580', 'Super'),
                  ]),
                  const Divider(height: 1),
                  _buildFuelRow('', '95', [
                    _buildPriceItem('assets/logos/pertamina.png', '13.000',
                        'Pertamax Green'),
                    _buildPriceItem(
                        'assets/logos/vivo.png', '13.050', 'Revvo95'),
                    _buildPriceItem(
                        'assets/logos/bp.png', '13.050', 'BP ultimate'),
                    _buildPriceItem(
                        'assets/logos/shell.png', '13.050', 'V-Power'),
                  ]),
                  const Divider(height: 1),
                  _buildFuelRow('', '98', [
                    _buildPriceItem('assets/logos/pertamina.png', '13.200',
                        'Pertamax Turbo'),
                    _buildPriceItem('assets/logos/vivo.png', '-', ''),
                    _buildPriceItem('assets/logos/bp.png', '-', ''),
                    _buildPriceItem(
                        'assets/logos/shell.png', '13.230', 'V-Power Nitro+'),
                  ]),
                ]),

                const SizedBox(height: 24),

                // Diesel Section
                _buildSectionTitle('Diesel'),
                const SizedBox(height: 12),
                _buildFuelTypeCard([
                  _buildFuelRow('CN', '48', [
                    _buildPriceItem(
                        'assets/logos/pertamina.png', '6.800', 'BioSolar'),
                    _buildPriceItem('assets/logos/vivo.png', '-', ''),
                    _buildPriceItem('assets/logos/bp.png', '-', ''),
                    _buildPriceItem('assets/logos/shell.png', '-', ''),
                  ]),
                  const Divider(height: 1),
                  _buildFuelRow('', '51', [
                    _buildPriceItem(
                        'assets/logos/pertamina.png', '13.850', 'DexLite'),
                    _buildPriceItem(
                        'assets/logos/vivo.png', '14.390', 'Primus Plus'),
                    _buildPriceItem(
                        'assets/logos/bp.png', '14.380', 'BP Ultimate Diesel'),
                    _buildPriceItem(
                        'assets/logos/shell.png', '14.380', 'V-Power Diesel'),
                  ]),
                  const Divider(height: 1),
                  _buildFuelRow('', '53', [
                    _buildPriceItem(
                        'assets/logos/pertamina.png', '14.150', 'Dex'),
                    _buildPriceItem('assets/logos/vivo.png', '-', ''),
                    _buildPriceItem('assets/logos/bp.png', '-', ''),
                    _buildPriceItem('assets/logos/shell.png', '-', ''),
                  ]),
                ]),

                const SizedBox(height: 16),
                Text(
                  'Data harga per ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        elevation: 6,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) => Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildFuelTypeCard(List<Widget> children) {
    return Builder(
      builder: (context) => Card(
        elevation: 2,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildFuelRow(
      String cnLabel, String ronNumber, List<Widget> priceItems) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // RON/CN Column
            SizedBox(
              width: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cnLabel.isNotEmpty)
                    Text(
                      cnLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  Text(
                    ronNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Price Items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: priceItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String logoPath, String price, String fuelName) {
    return Builder(
      builder: (context) => Expanded(
        child: Column(
          children: [
            // Logo
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                logoPath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.local_gas_station,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              price,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: price == '-'
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            // Fuel Name
            if (fuelName.isNotEmpty)
              Text(
                fuelName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
