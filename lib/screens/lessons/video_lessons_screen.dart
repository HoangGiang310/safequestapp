import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // 12 video mẫu phân bổ đều cho 4 chủ đề chính (mỗi chủ đề 3 video)
  static final Map<String, List<LessonVideo>> _defaultVideosByTopic = {
    't1': [
      LessonVideo(
        id: 'v_t1_1',
        topicId: 't1',
        title: 'Nhận biết tín hiệu đèn giao thông & vạch kẻ đường',
        description: 'Bé học cách phân biệt đèn xanh, đèn đỏ, đèn vàng và quy tắc đi bộ an toàn trên vạch ngựa vằn.',
        duration: '03:45',
        order: 1,
      ),
      LessonVideo(
        id: 'v_t1_2',
        topicId: 't1',
        title: 'Kỹ năng đi bộ qua đường an toàn cùng người lớn',
        description: 'Cách quan sát trái phải trước khi qua đường và luôn nắm tay người lớn khi ở nơi đông xe cộ.',
        duration: '04:15',
        order: 2,
      ),
      LessonVideo(
        id: 'v_t1_3',
        topicId: 't1',
        title: 'Đội mũ bảo hiểm đúng cách khi ngồi xe máy',
        description: 'Vì sao bé cần đội mũ bảo hiểm và cách cài quai nón vừa vặn để bảo vệ an toàn cho đầu.',
        duration: '03:20',
        order: 3,
      ),
    ],
    't2': [
      LessonVideo(
        id: 'v_t2_1',
        topicId: 't2',
        title: 'Phòng tránh bỏng và nguy hiểm từ nước sôi, bếp lửa',
        description: 'Bé nhận biết những vật dụng nóng nguy hiểm trong nhà và tuyệt đối không nghịch gần bếp.',
        duration: '03:50',
        order: 1,
      ),
      LessonVideo(
        id: 'v_t2_2',
        topicId: 't2',
        title: 'An toàn với các ổ cắm điện và thiết bị gia dụng',
        description: 'Điện vô cùng nguy hiểm! Bé không được chọc que vào ổ cắm hay chạm tay ướt vào dây điện.',
        duration: '04:05',
        order: 2,
      ),
      LessonVideo(
        id: 'v_t2_3',
        topicId: 't2',
        title: 'Cẩn thận lan can, cửa sổ và trơn trượt cầu thang',
        description: 'Không leo trèo lên bàn ghế gần cửa sổ, luôn bám vào tay vịn khi đi lên xuống cầu thang.',
        duration: '03:30',
        order: 3,
      ),
    ],
    't3': [
      LessonVideo(
        id: 'v_t3_1',
        topicId: 't3',
        title: 'Quy tắc an toàn khi chơi gần ao, hồ, sông suối',
        description: 'Phòng chống đuối nước: Bé tuyệt đối không tự ý lại gần mép nước nếu không có áo phao và người lớn.',
        duration: '04:30',
        order: 1,
      ),
      LessonVideo(
        id: 'v_t3_2',
        topicId: 't3',
        title: 'Ứng phó khi gặp mưa giông, sấm sét ngoài trời',
        description: 'Tìm nơi trú ẩn an toàn, không đứng dưới gốc cây to hoặc cầm que kim loại khi có sét.',
        duration: '03:40',
        order: 2,
      ),
      LessonVideo(
        id: 'v_t3_3',
        topicId: 't3',
        title: 'Vui chơi an toàn tại công viên và khu trò chơi',
        description: 'Biết xếp hàng chờ đến lượt ở cầu trượt, xích đu và không chen lấn xô đẩy các bạn.',
        duration: '03:15',
        order: 3,
      ),
    ],
    't4': [
      LessonVideo(
        id: 'v_t4_1',
        topicId: 't4',
        title: 'Quy tắc 5 ngón tay phòng chống xâm hại',
        description: 'Bài học 5 ngón tay bảo vệ cơ thể: Biết ai được ôm, ai được bắt tay và ai bé cần giữ khoảng cách.',
        duration: '04:45',
        order: 1,
      ),
      LessonVideo(
        id: 'v_t4_2',
        topicId: 't4',
        title: 'Nói KHÔNG khi người lạ cho kẹo, đồ chơi hoặc rủ đi',
        description: 'Tuyệt đối không nhận quà và không đi theo bất kỳ ai lạ mặt khi chưa được bố mẹ đồng ý.',
        duration: '03:55',
        order: 2,
      ),
      LessonVideo(
        id: 'v_t4_3',
        topicId: 't4',
        title: 'Kỹ năng tìm sự giúp đỡ khi bị lạc nơi đông người',
        description: 'Khi bị lạc ở siêu thị hoặc công viên, bé hãy đứng yên và tìm chú công an hoặc nhân viên bảo vệ.',
        duration: '04:10',
        order: 3,
      ),
    ],
  };

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

    final videos = _defaultVideosByTopic[_selectedTopicId] ?? [];

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

  Widget _buildVideoCard(BuildContext context, LessonVideo video, int number, Color topicColor) {
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
          // Video Mockup Player Frame
          GestureDetector(
            onTap: () => _onTapVideo(context, video),
            child: Stack(
              children: [
                Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withOpacity(0.5),
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
                ),
                // Lesson index badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
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
                // Duration badge
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

          // Video Meta Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  video.description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_library_rounded, size: 14, color: Color(0xFFE65100)),
                          SizedBox(width: 4),
                          Text(
                            'Sẵn sàng gắn video',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE65100),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTapVideo(BuildContext context, LessonVideo video) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.smart_display_rounded, size: 36, color: Color(0xFFE53935)),
                ),
              ),
              const SizedBox(height: 14),
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
                video.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vị trí video này đã sẵn sàng. Bạn có thể gắn đường link YouTube bài giảng vào để bé xem trực tiếp trong app!',
                        style: TextStyle(
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
    );
  }
}
