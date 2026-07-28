import 'package:el_race/data/models/announcement_model.dart';
import 'package:el_race/data/services/announcements_api_service.dart';
import 'package:el_race/ui/presentation/News%20Banner/bloc/news_bloc.dart';
import 'package:el_race/ui/presentation/News%20Banner/bloc/news_event.dart';
import 'package:el_race/ui/presentation/News%20Banner/bloc/news_state.dart';
import 'package:el_race/ui/presentation/News%20Banner/news_detail_screen_api.dart';
import 'package:el_race/ui/widgets/header_widget.dart';
import 'package:el_race/utils/color_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc()
        ..add(const NewsRequested(category: AnnouncementCategory.news)),
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatelessWidget {
  const _NewsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HeaderWidget(),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/png/news_logo.png',
                            height: 24.h,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.article,
                                size: 24.h,
                                color: appFontColor),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            translate('home.news'),
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              color: appFontColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Content based on state
                if (state.isLoading)
                  _buildLoadingState()
                else if (state.hasError)
                  _buildErrorState(context, state)
                else if (state.isEmpty)
                  _buildEmptyState()
                else if (state.hasData)
                  _buildNewsList(state.announcements),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<NewsBloc>()..add(const NewsRefreshRequested());
    await bloc.stream.firstWhere((state) => !state.isLoading);
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appFontColor),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading news...',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, NewsState state) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: Colors.red[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'Error',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<NewsBloc>().add(const NewsRefreshRequested()),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appFontColor,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No News Available',
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'There are no news items to display at the moment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build news list
  Widget _buildNewsList(List<AnnouncementModel> newsList) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final newsItem = newsList[index];
            return _buildNewsCard(context, newsItem,
                isLast: index == newsList.length - 1);
          },
          childCount: newsList.length,
        ),
      ),
    );
  }

  /// Build individual news card
  Widget _buildNewsCard(
    BuildContext context,
    AnnouncementModel newsItem, {
    required bool isLast,
  }) {
    final bottomMargin = isLast ? (kBottomNavigationBarHeight + 20.h) : 3.h;

    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreenAPI(newsItem: newsItem),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(5.w, 15.h, 0, 10.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD6D6D6),
                    Color(0xFFADB2BD),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.46),
                    offset: Offset(0, 10),
                    blurRadius: 9.6,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  newsItem.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: appFontColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 24.sp,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  _buildNewsImage(newsItem),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            const Color(0xFF000000).withValues(alpha: 0.50),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 12.w,
                top: 10.h,
                bottom: 14.h,
              ),
              child: _buildReferenceDescription(context, newsItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsImage(AnnouncementModel newsItem) {
    final imageUrl = newsItem.attachmentUrl;

    if (newsItem.hasAttachment && imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200.w,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/jpeg/slide_1_c.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200.w,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200.w,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return Image.asset(
      'assets/jpeg/slide_1_c.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 200.w,
    );
  }

  Widget _buildReferenceDescription(
    BuildContext context,
    AnnouncementModel newsItem,
  ) {
    final description = newsItem.description.trim();
    final preview = description.length > 165
        ? '${description.substring(0, 165).trim()}...'
        : description;

    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.black,
          height: 1.65,
        ),
        children: [
          TextSpan(text: preview),
          TextSpan(
            text: '  See All',
            style: GoogleFonts.poppins(
              color: const Color(0xFF868686),
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewsDetailScreenAPI(newsItem: newsItem),
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
