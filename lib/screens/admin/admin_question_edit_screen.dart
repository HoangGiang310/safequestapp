import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../services/data_service.dart';

class AdminQuestionEditScreen extends StatefulWidget {
  final Topic topic;
  final Question? question;

  const AdminQuestionEditScreen({super.key, required this.topic, this.question});

  @override
  State<AdminQuestionEditScreen> createState() => _AdminQuestionEditScreenState();
}

class _AdminQuestionEditScreenState extends State<AdminQuestionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _questionCtrl;
  late TextEditingController _hintCtrl;
  late TextEditingController _explanationCtrl;
  late TextEditingController _dialogueCtrl;
  late TextEditingController _levelNumberCtrl;
  
  late List<TextEditingController> _optionCtrls;
  
  QuestionType _selectedType = QuestionType.singleChoice;
  List<int> _correctAnswers = [];
  bool _isActive = true;

  String? _imagePath;
  
  @override
  void initState() {
    super.initState();
    
    final q = widget.question;
    
    _questionCtrl = TextEditingController(text: q?.question ?? '');
    _hintCtrl = TextEditingController(text: q?.hint ?? '');
    _explanationCtrl = TextEditingController(text: q?.explanation ?? '');
    _dialogueCtrl = TextEditingController(text: q?.characterDialogue ?? '');

    final initialLevel = q?.levelId ?? '${widget.topic.id}_l1';
    final levelMatch = RegExp(r'_l(\d+)$').firstMatch(initialLevel);
    final initialLevelNumber = levelMatch != null ? int.tryParse(levelMatch.group(1) ?? '') ?? 1 : 1;

    _selectedType = q?.type ?? QuestionType.singleChoice;
    _correctAnswers = List.from(q?.correctAnswers ?? []);
    _isActive = q?.isActive ?? true;
    _imagePath = q?.image;
    _levelNumberCtrl = TextEditingController(text: initialLevelNumber.toString());

    final opts = q?.options ?? ['', '', '', ''];
    _optionCtrls = List.generate(
      opts.length > 4 ? opts.length : 4, 
      (i) => TextEditingController(text: i < opts.length ? opts[i] : '')
    );
  }
  
  @override
  void dispose() {
    _questionCtrl.dispose();
    _hintCtrl.dispose();
    _explanationCtrl.dispose();
    _dialogueCtrl.dispose();
    _levelNumberCtrl.dispose();
    for (var c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final levelNumber = int.tryParse(_levelNumberCtrl.text.trim());
    if (levelNumber == null || levelNumber < 1 || levelNumber > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập trong khoảng 1-100', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_correctAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất 1 đáp án đúng.')));
      return;
    }

    final options = _optionCtrls.map((c) => c.text).where((s) => s.isNotEmpty).toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phải có ít nhất 2 đáp án.')));
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final targetLevelId = '${widget.topic.id}_l$levelNumber';
    final existingLevel = (await DataService().getLevels()).firstWhere(
      (level) => level.id == targetLevelId,
      orElse: () => Level(
        id: targetLevelId,
        topicId: widget.topic.id,
        title: 'Cấp độ $levelNumber',
        description: 'Cấp độ do admin tạo',
        order: levelNumber,
      ),
    );
    await appProvider.saveLevel(existingLevel);

    final newQ = Question(
      id: widget.question?.id ?? '${widget.topic.id}_q_${DateTime.now().millisecondsSinceEpoch}',
      levelId: targetLevelId,
      type: _selectedType,
      question: _questionCtrl.text,
      options: options,
      correctAnswers: _correctAnswers,
      hint: _hintCtrl.text,
      explanation: _explanationCtrl.text,
      image: _imagePath,
      characterDialogue: _selectedType == QuestionType.dialogue ? _dialogueCtrl.text : null,
      isActive: _isActive,
    );

    await appProvider.saveQuestion(newQ);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật câu hỏi và cấp độ trên app!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.question == null ? 'Thêm câu hỏi mới' : 'Sửa câu hỏi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF4A6572),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Box Thông số chung
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phân loại & Trạng thái', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _levelNumberCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Cấp độ',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (value) {
                              final levelNumber = int.tryParse(value?.trim() ?? '');
                              if (levelNumber == null || levelNumber < 1 || levelNumber > 100) {
                                return 'Vui lòng nhập trong khoảng 1-100';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<QuestionType>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Loại câu hỏi',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: const [
                              DropdownMenuItem(value: QuestionType.singleChoice, child: Text('1 Đáp án')),
                              DropdownMenuItem(value: QuestionType.multipleChoice, child: Text('Nhiều đáp án')),
                              DropdownMenuItem(value: QuestionType.dialogue, child: Text('Hội thoại')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedType = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isActive ? AppColors.successLight : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hiển thị trên App', style: TextStyle(color: _isActive ? AppColors.success : Colors.grey, fontWeight: FontWeight.bold)),
                          Switch(
                            value: _isActive,
                            activeColor: AppColors.success,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Box Nội dung
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nội dung', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    if (_selectedType == QuestionType.dialogue) ...[
                      TextFormField(
                        controller: _dialogueCtrl,
                        decoration: InputDecoration(
                          labelText: 'Lời thoại nhân vật',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'Vui lòng nhập lời thoại' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    TextFormField(
                      controller: _questionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Câu hỏi',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập câu hỏi' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    Text('Hình minh họa (Tùy chọn)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cartoonBorder, width: 2),
                              boxShadow: const [
                                BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 3), blurRadius: 0),
                              ],
                            ),
                            child: const Text(
                              'CHỌN HÌNH MINH HỌA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        if (_imagePath != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success, width: 1.5),
                            ),
                            child: const Text(
                              'ĐÃ CHỌN ẢNH',
                              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _imagePath = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error, width: 1.5),
                              ),
                              child: const Text(
                                'XÓA ẢNH',
                                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    if (_imagePath != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImagePreviewWidget(_imagePath!),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Box Đáp án
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Các đáp án', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    const Text('Check vào ô để chọn đáp án đúng.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                    
                    ...List.generate(_optionCtrls.length, (index) {
                      final isCorrect = _correctAnswers.contains(index);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppColors.successLight : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isCorrect ? AppColors.success : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: isCorrect ? AppColors.success : Colors.white, shape: BoxShape.circle),
                              child: Center(child: Text(String.fromCharCode(65 + index), style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? Colors.white : Colors.black))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _optionCtrls[index],
                                decoration: const InputDecoration(
                                  hintText: 'Nhập đáp án...',
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: isCorrect,
                              activeColor: AppColors.success,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    if (_selectedType != QuestionType.multipleChoice) {
                                      _correctAnswers.clear(); 
                                    }
                                    _correctAnswers.add(index);
                                  } else {
                                    _correctAnswers.remove(index);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Box Gợi ý & Giải thích
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hỗ trợ bé', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hintCtrl,
                      decoration: InputDecoration(
                        labelText: 'Gợi ý (Khi trả lời sai)',
                        filled: true,
                        fillColor: AppColors.warning.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      maxLines: 2,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập gợi ý' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _explanationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Giải thích (Khi trả lời đúng)',
                        filled: true,
                        fillColor: AppColors.successLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập giải thích' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'LƯU CÂU HỎI',
                color: const Color(0xFF4A6572),
                onPressed: _save,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewWidget(String path) {
    if (path.startsWith('assets/')) {
      if (path.endsWith('.svg')) {
        return SvgPicture.asset(
          path,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
      return Image.asset(
        path,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      if (path.endsWith('.svg')) {
        return SvgPicture.network(
          path,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
      return Image.network(
        path,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.file(
      File(path),
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
