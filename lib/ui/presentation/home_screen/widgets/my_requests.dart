import 'package:el_race/core/theme/app_colors.dart';
import 'package:el_race/utils/string_utils.dart';
import 'package:flutter/material.dart';

class MyRequests extends StatelessWidget {
  final String title;
  const MyRequests({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
            color: AppThemeColors.lightGrey,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: AppThemeColors.darkGrey,
                  offset: Offset(2, 4),
                  blurRadius: 12)
            ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('$imagePrefixIcons/fav2.png'),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        color: AppThemeColors.brandBlue,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          height: 60,
                          width: 320,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: AppThemeColors.softWhite,
                              boxShadow: const [
                                BoxShadow(
                                    color: AppThemeColors.darkGrey,
                                    offset: Offset(2, 4),
                                    blurRadius: 12)
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset('$imagePrefixIcons/fav2.png'),
                                Container(
                                  color: AppThemeColors.darkGrey,
                                  width: 2,
                                  height: 50,
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'ANNUAL LEAVE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppThemeColors.brandBlue),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          color: AppThemeColors.legacyRed,
                                          child: const Center(
                                            child: Text(
                                              '1',
                                              style: TextStyle(
                                                  color:
                                                      AppThemeColors.softWhite),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text(
                                          'ANNUAL LEAVE',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppThemeColors.darkGrey,
                                              fontSize: 10),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                  color: AppThemeColors.darkGrey,
                                  width: 2,
                                  height: 50,
                                ),
                                const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'REQUESTED',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppThemeColors.darkGrey),
                                    ),
                                    Text(
                                      '2 DAYS AGO',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppThemeColors.darkGrey),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppThemeColors.brandBlue,
                                          width: 2)),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemCount: 3)
            ],
          ),
        ),
      ),
    );
  }
}
