import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';
import '../topics/topic_detail_screen.dart';

class VideoLessonsScreen extends StatefulWidget {
  final String? initialTopicId;

  const VideoLessonsScreen({
    super.key,
    this.initialTopicId,
  });

  @override
  State<VideoLessonsScreen> createState() => _VideoLessonsScreenState();
}

class _VideoLessonsScreenState extends State<VideoLessonsScreen> {
  late String _selectedTopicId;

  @override
  void initState() {
    super.initState();
    _selectedTopicId = widget.initialTopicId ?? 't1';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final topics = provider.topics.isNotEmpty ? provider.topics : MockContentRepository.topics;
    final currentTopic = topics.firstWhere(
      (t) => t.id == _selectedTopicId,
      orElse: () => topics.first,
    );
    final topicColor = Color(currentTopic.colorValue);

    final videos = provider.getVideosForTopic(_selectedTopicId);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF6FF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cartoonBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFD0E1FD),
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'QUAY LẠI',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Video Bài Giảng',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB39DDB), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎬', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 4),
                        Text(
                          '4 Chủ đề',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF512DA8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Cinema Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF311B92), width: 2.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF311B92),
                            offset: Offset(0, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                            ),
                            child: const Center(
                              child: Text('📺', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rạp Chiếu Bài Học An Toàn',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Bé xem hoạt hình sinh động để nắm vững các kỹ năng an toàn nhé!',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE0E7FF),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Topic Selector Horizontal Pills (4 chủ đề chính)
                    const Text(
                      'Chọn chủ đề bài giảng:',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: topics.map((t) {
                          final isSelected = t.id == _selectedTopicId;
                          final color = Color(t.colorValue);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTopicId = t.id;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? color : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.black.withOpacity(0.2) : const Color(0xFFD6E4FF),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? color.withOpacity(0.4)
                                          : const Color(0xFFD0E1FD),
                                      offset: const Offset(0, 3.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(t.icon, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      t.title,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Topic Header Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: topicColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: topicColor.withOpacity(0.35), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(currentTopic.icon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTopic.title,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: topicColor,
                                  ),
                                ),
                                const Text(
                                  'Danh sách 3 video bài giảng chọn lọc',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: topicColor, width: 1.2),
                            ),
                            child: Text(
                              '3 Video',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: topicColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3 Video Cards of Selected Topic
                    ...List.generate(videos.length, (index) {
                      final video = videos[index];
                      return _buildVideoCard(context, video, index + 1, topicColor);
                    }),

                    const SizedBox(height: 10),

                    // Quick Practice Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopicDetailScreen(topic: currentTopic),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: topicColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black.withOpacity(0.15), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: topicColor.withOpacity(0.4),
                              offset: const Offset(0, 4.5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('⭐', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'LÀM BÀI TẬP ÔN LUYỆN CHỦ ĐỀ NÀY',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYouTube(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch $url: $e');
      }
    }
  }

  Widget _buildThumbnailWidget(String url) {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: Icon(Icons.smart_display_rounded, size: 54, color: Colors.white24),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: Icon(Icons.smart_display_rounded, size: 54, color: Colors.white24),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, LessonVideo video, int number, Color topicColor) {
    final hasUrl = video.youtubeUrl.trim().isNotEmpty;
    final thumbUrl = video.effectiveThumbnailUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6E4FF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0E1FD),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player / Thumbnail Frame
          GestureDetector(
            onTap: () => _onTapVideo(context, video),
            child: Stack(
              children: [
                Container(
                  height: 165,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (thumbUrl != null)
                          _buildThumbnailWidget(thumbUrl)
                        else
                          Container(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: Icon(Icons.smart_display_rounded, size: 54, color: Colors.white24),
                            ),
                          ),
                        // Dark soft overlay for text & button contrast
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.35),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Center Play Button
                        Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE53935).withOpacity(0.55),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Lesson index badge (Top Left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Bài $number / 3',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // YouTube pill badge (Top Right)
                if (hasUrl)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'YouTube',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Duration badge (Bottom Right)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          video.duration,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar: Status & Play action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasUrl ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasUrl ? Icons.check_circle_rounded : Icons.video_library_rounded,
                        size: 14,
                        color: hasUrl ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hasUrl ? 'Sẵn sàng xem' : 'Chưa có video',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: hasUrl ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _onTapVideo(context, video),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB71C1C).withOpacity(0.4),
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'PHÁT VIDEO',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTapVideo(BuildContext context, LessonVideo video) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isAdmin = provider.isAdmin;
    final urlController = TextEditingController(text: video.youtubeUrl);
    final hasUrl = video.youtubeUrl.trim().isNotEmpty;
    final thumbUrl = video.effectiveThumbnailUrl;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.cartoonBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cartoonBorder,
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon / Thumbnail preview
                if (thumbUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD6E4FF), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildThumbnailWidget(thumbUrl),
                          Container(
                            color: Colors.black.withOpacity(0.3),
                          ),
                          Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.smart_display_rounded, size: 36, color: Color(0xFFE53935)),
                    ),
                  ),

                const Text(
                  'Chuẩn Bị Video Bài Giảng',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  video.title.isNotEmpty ? video.title : 'Bài ${video.order}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (video.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 14),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Color(0xFF475569)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasUrl
                              ? 'Đã gắn link YouTube: ${video.youtubeUrl}'
                              : 'Vị trí video này đã sẵn sàng. Bạn có thể gắn đường link YouTube bài giảng vào để bé xem trực tiếp trong app!',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Open YouTube Button (if URL available)
                if (hasUrl) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      _openYouTube(video.youtubeUrl);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C1C).withOpacity(0.4),
                            offset: const Offset(0, 3.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.smart_display_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'MỞ XEM TRÊN YOUTUBE 🚀',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Admin Editing Panel
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded, size: 16, color: Color(0xFFE65100)),
                            SizedBox(width: 6),
                            Text(
                              'ADMIN: GẮN LINK YOUTUBE',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            hintText: 'https://www.youtube.com/watch?v=...',
                            hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final newUrl = urlController.text.trim();
                            final updated = video.copyWith(youtubeUrl: newUrl);
                            await provider.saveLessonVideo(updated);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã cập nhật link video lên Firebase thành công! 🎉'),
                                  backgroundColor: Color(0xFF2E7D32),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'LƯU VÀO FIREBASE',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.primaryDark,
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'ĐÃ HIỂU',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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
