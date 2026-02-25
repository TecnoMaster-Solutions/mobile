import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_states.dart';

class ProductsPieChartWidget extends StatelessWidget {
  const ProductsPieChartWidget({super.key});

  //Paleta de colores de claro a oscuro
  final List<Color> colors = const [
    Color(0xFFE60000),
    Color(0xFFD00000),
    Color(0xFFB20000),
    Color(0xFF990000),
    Color(0xFF800000),
    Color(0xFF660000),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          final categories = state.products.keys.toList();
          final values = state.products.values.toList();
          final total = values.reduce((a, b) => a + b);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Encabezado
                const Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.black, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Cantidad de productos por categoría",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                //Gráfico de torta
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: List.generate(categories.length, (i) {
                        final percent =
                            ((values[i] / total) * 100).toStringAsFixed(0);
                        return PieChartSectionData(
                          value: values[i],
                          color: colors[i % colors.length],
                          radius: 90,
                          title: "$percent%",
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //Título centrado de la leyenda
                const Text(
                  "Categoría de productos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),

                // Leyenda
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 32,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            categories[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        } else if (state is ProductsError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
