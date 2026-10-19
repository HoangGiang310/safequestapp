import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/models.dart';
import '../data/mock_data.dart';
import '../services/data_service.dart';
import '../app.dart';
import '../screens/auth/login_screen.dart';
import '../core/theme/app_colors.dart';

class AppProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  StreamSubscription<DocumentSnapshot>? _sessionSubscription;
  String? _myCurrentSessionId;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Account? _currentAccount;
  Account? get currentAccount => _currentAccount;

  bool get isLoggedIn => _currentAccount != null;
  bool get isAdmin => _currentAccount?.role == Role.ADMIN;

  ChildProfile? _profile;
  ChildProfile? get profile => _profile;

  // Transactions
  List<Transaction> _myTransactions = [];
  List<Transaction> get myTransactions => _myTransactions;
  
  List<Transaction> _allTransactions = [];
  List<Transaction> get allTransactions => _allTransactions;

  // Caching content
  List<Topic> _topics = [];
  List<Level> _levels = [];
  List<Question> _questions = [];

  List<Topic> get topics => _topics.where((t) => t.isActive).toList();
  List<Topic> get adminTopics => _topics;
  
  List<Level> get levels => _levels;
  
  List<Question> get questions => _questions;

  // Progress map
  Map<String, bool> _progress = {};
  
  List<String> _wrongQuestions = [];
  List<String> get wrongQuestions => _wrongQuestions;

  List<String> _unlockedBadges = [];
  List<String> get unlockedBadges => _unlockedBadges;

  List<String> _recentUnlockedBadges = [];
  List<String> get recentUnlockedBadges => List.unmodifiable(_recentUnlockedBadges);
  void clearRecentUnlockedBadges() {
    _recentUnlockedBadges.clear();
  }

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await DataService().init();
    _prefs = await SharedPreferences.getInstance();
    
    await _loadContent();

    final accountId = _prefs?.getInt('currentAccountId');
    if (accountId != null) {
      final accounts = await DataService().getAccounts();
      try {
        _currentAccount = accounts.firstWhere((e) => e.id == accountId);
        
        if (_currentAccount?.role == Role.CUSTOMER) {
          _profile = await DataService().getChildProfileByAccountId(accountId);
          await _loadMyTransactions();
          if (_profile != null) {
            _loadProgressData();
            _checkAndUpdateStreak();
          }
        }

        // Restore or initialize session listener
        String? mySessionId = _prefs?.getString('myCurrentSessionId');
        if (mySessionId == null) {
          mySessionId = '${DateTime.now().millisecondsSinceEpoch}_${accountId}_${math.Random().nextInt(99999)}';
          await _prefs?.setString('myCurrentSessionId', mySessionId);
          try {
            await FirebaseFirestore.instance
                .collection('accounts')
                .doc(accountId.toString())
                .set({'currentSessionId': mySessionId}, SetOptions(merge: true));
          } catch (_) {}
        }
        _startSessionListener(accountId, mySessionId);
      } catch (e) {
        _currentAccount = null;
      }
    }
    
    _isInitialized = true;
    notifyListeners();
  }
  
  Future<void> _loadContent() async {
    _topics = await DataService().getTopics();
    _levels = await DataService().getLevels();
    _questions = await DataService().getQuestions();
  }
  
  void _loadProgressData() {
    if (_profile != null) {
      for (var levelId in _profile!.completedLevels) {
        _progress[levelId] = true;
      }
      _wrongQuestions = List.from(_profile!.wrongQuestions);
      _unlockedBadges = List.from(_profile!.unlockedBadges);
    }
  }

  // --- CONTENT MANAGEMENT ---

  Future<void> saveTopic(Topic topic) async {
    await DataService().saveTopic(topic);
    await _loadContent();
    notifyListeners();
  }

  Future<void> saveLevel(Level level) async {
    await DataService().saveLevel(level);
    await _loadContent();
    notifyListeners();
  }

  Future<void> saveQuestion(Question question) async {
    await DataService().saveQuestion(question);
    await _loadContent();
    notifyListeners();
  }

  Future<void> deleteQuestion(String questionId) async {
    await DataService().deleteQuestion(questionId);
    await _loadContent();
    notifyListeners();
  }

  // --- AUTHENTICATION ---
  
  Future<void> reloadAdminContent() async {
    await _loadContent();
    if (isAdmin) {
      _allTransactions = await DataService().getTransactions();
    }
    notifyListeners();
  }
  
  Future<void> _loadMyTransactions() async {
    if (_currentAccount != null) {
      _myTransactions = await DataService().getTransactionsByUserId(_currentAccount!.id);
      _myTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<void> reloadAccountData() async {
    if (_currentAccount != null) {
      _currentAccount = await DataService().getAccountById(_currentAccount!.id);
      await _loadMyTransactions();
      notifyListeners();
    }
  }
  
  Future<bool> login(String username, String password) async {
    final account = await DataService().authenticate(username, password);
    if (account != null) {
      _currentAccount = account;
      await _prefs?.setInt('currentAccountId', account.id);

      // Generate unique session ID for this device login
      final sessionId = '${DateTime.now().millisecondsSinceEpoch}_${account.id}_${math.Random().nextInt(99999)}';
      _myCurrentSessionId = sessionId;
      await _prefs?.setString('myCurrentSessionId', sessionId);

      try {
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(account.id.toString())
            .set({'currentSessionId': sessionId}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error syncing currentSessionId on login: $e');
      }

      _startSessionListener(account.id, sessionId);

      await _loadContent();
      
      if (account.role == Role.CUSTOMER) {
        _profile = await DataService().getChildProfileByAccountId(account.id);
        await _loadMyTransactions();
        if (_profile != null) {
          _loadProgressData();
          _checkAndUpdateStreak();
        }
      } else if (account.role == Role.ADMIN) {
         _allTransactions = await DataService().getTransactions();
      }
      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<bool> register(String username, String password) async {
    final newAccount = await DataService().registerAccount(username, password);
    if (newAccount != null) {
      _currentAccount = newAccount;
      await _prefs?.setInt('currentAccountId', newAccount.id);

      final sessionId = '${DateTime.now().millisecondsSinceEpoch}_${newAccount.id}_${math.Random().nextInt(99999)}';
      _myCurrentSessionId = sessionId;
      await _prefs?.setString('myCurrentSessionId', sessionId);

      try {
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(newAccount.id.toString())
            .set({'currentSessionId': sessionId}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error syncing currentSessionId on register: $e');
      }

      _startSessionListener(newAccount.id, sessionId);

      notifyListeners();
      return true;
    }
    return false;
  }

  void _startSessionListener(int accountId, String mySessionId) {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _myCurrentSessionId = mySessionId;

    try {
      _sessionSubscription = FirebaseFirestore.instance
          .collection('accounts')
          .doc(accountId.toString())
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final remoteSessionId = snapshot.data()?['currentSessionId'] as String?;
          if (remoteSessionId != null &&
              _myCurrentSessionId != null &&
              remoteSessionId != _myCurrentSessionId) {
            debugPrint('Single session violation: remote=$remoteSessionId != current=$_myCurrentSessionId');
            _handleKickedOut();
          }
        }
      }, onError: (err) {
        debugPrint('Session listener error: $err');
      });
    } catch (e) {
      debugPrint('Error starting session listener: $e');
    }
  }

  void _handleKickedOut() async {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _myCurrentSessionId = null;

    await logout();

    final navContext = SafeQuestApp.navigatorKey.currentContext;
    if (navContext != null) {
      Navigator.of(navContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      showDialog(
        context: SafeQuestApp.navigatorKey.currentContext ?? navContext,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.cartoonBorder, width: 3),
          ),
          title: const Row(
            children: [
              Text('⚠️ ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'ĐĂNG XUẤT THIẾT BỊ',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          content: const Text(
            'Tài khoản này vừa được đăng nhập trên một thiết bị khác. Bạn đã bị đăng xuất để bảo đảm an toàn!',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cartoonBorder, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text('ĐÃ HIỂU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout() async {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _myCurrentSessionId = null;
    await _prefs?.remove('myCurrentSessionId');

    _currentAccount = null;
    _profile = null;
    _progress = {};
    _wrongQuestions = [];
    _unlockedBadges = [];
    _recentUnlockedBadges = [];
    _myTransactions = [];
    _allTransactions = [];
    await _prefs?.remove('currentAccountId');
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanUsername = username.trim();
    if (cleanUsername.isEmpty || oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return {'success': false, 'message': 'Vui lòng nhập đầy đủ các trường thông tin.'};
    }

    if (_currentAccount == null || _currentAccount!.username.trim().toLowerCase() != cleanUsername.toLowerCase()) {
      return {'success': false, 'message': 'Tài khoản không trùng khớp với tài khoản hiện tại.'};
    }

    if (_currentAccount!.password != oldPassword) {
      return {'success': false, 'message': 'Mật khẩu cũ không chính xác.'};
    }

    if (newPassword.length < 6) {
      return {'success': false, 'message': 'Mật khẩu mới phải có tối thiểu 6 ký tự.'};
    }

    if (newPassword == oldPassword) {
      return {'success': false, 'message': 'Mật khẩu mới phải khác với mật khẩu cũ.'};
    }

    if (newPassword != confirmPassword) {
      return {'success': false, 'message': 'Xác nhận mật khẩu mới không khớp.'};
    }

    final success = await DataService().changePassword(
      username: cleanUsername,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (success) {
      _currentAccount = _currentAccount!.copyWith(password: newPassword);
      notifyListeners();
      return {'success': true, 'message': 'Đổi mật khẩu thành công!'};
    } else {
      return {'success': false, 'message': 'Không thể đổi mật khẩu. Vui lòng thử lại.'};
    }
  }

  // --- PROFILE ---

  Future<void> saveProfile(String name, int age, String avatar) async {
    if (_currentAccount == null) return;
    
    _profile = ChildProfile(
      id: 'child_${_currentAccount!.id}',
      accountId: _currentAccount!.id,
      name: name,
      age: age,
      avatar: avatar,
      points: _profile?.points ?? 0,
      streak: _profile?.streak ?? 0,
      longestStreak: _profile?.longestStreak ?? 0,
      lastStudyDate: _profile?.lastStudyDate,
      studyDates: _profile?.studyDates ?? [],
      unlockedBadges: _unlockedBadges,
      completedLevels: _progress.keys.toList(),
      wrongQuestions: _wrongQuestions,
    );
    await DataService().saveChildProfile(_profile!);
    notifyListeners();
  }

  Future<void> updateProfile({String? name, int? age, String? avatar, int? addPoints}) async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        name: name,
        age: age,
        avatar: avatar,
        points: addPoints != null ? _profile!.points + addPoints : null,
      );
      if (addPoints != null) {
        _checkBadges();
      }
      await DataService().saveChildProfile(_profile!);
      notifyListeners();
    }
  }

  Future<void> _saveProfileInternal() async {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        completedLevels: _progress.keys.toList(),
        wrongQuestions: _wrongQuestions,
        unlockedBadges: _unlockedBadges,
      );
      await DataService().saveChildProfile(_profile!);
    } else if (_currentAccount != null) {
      _profile = ChildProfile(
        id: 'child_${_currentAccount!.id}',
        accountId: _currentAccount!.id,
        name: _currentAccount!.username,
        age: 7,
        avatar: '👦',
        points: 0,
        streak: 0,
        longestStreak: 0,
        studyDates: [],
        unlockedBadges: _unlockedBadges,
        completedLevels: _progress.keys.toList(),
        wrongQuestions: _wrongQuestions,
      );
      await DataService().saveChildProfile(_profile!);
    }
  }

  // --- GAME & PROGRESS ---

  bool isLevelUnlocked(String levelId) {
    final match = RegExp(r'_l(\d+)$').firstMatch(levelId);
    if (match == null) return true;

    final levelNumber = int.tryParse(match.group(1) ?? '');
    if (levelNumber == null || levelNumber <= 1) return true;

    final topicId = levelId.substring(0, levelId.lastIndexOf('_l'));
    final previousLevelId = '${topicId}_l${levelNumber - 1}';
    return _progress[previousLevelId] == true;
  }

  bool isLevelCompleted(String levelId) {
    return _progress[levelId] == true;
  }

  double getTopicProgress(String topicId) {
    final topicLevels = _levels.where((level) => level.topicId == topicId).toList();
    if (topicLevels.isEmpty) return 0.0;

    final completedCount = topicLevels.where((level) => _progress[level.id] == true).length;
    return completedCount / topicLevels.length;
  }

  int getCompletedLevelsCount(String topicId) {
    final topicLevels = _levels.where((level) => level.topicId == topicId).toList();
    return topicLevels.where((level) => _progress[level.id] == true).length;
  }

  Future<List<String>> completeLevel(String levelId, int scoreEarned, {bool isCompleted = true, DateTime? completionDate}) async {
    final bool wasAlreadyCompleted = _progress[levelId] == true;
    
    // Nếu isCompleted = false (sai cả 3 câu), KHÔNG đánh dấu là đã hoàn thành
    if (isCompleted) {
      _progress[levelId] = true;
    }
    
    // Chỉ cộng điểm khi đây là level mới, được hoàn thành và điểm > 0
    if (isCompleted && !wasAlreadyCompleted && _profile != null && scoreEarned > 0) {
      _profile = _profile!.copyWith(
        points: _profile!.points + scoreEarned,
      );
    }

    // Khi người dùng hoàn thành ít nhất 1 level mới trong ngày (không tính level cũ đã vượt qua),
    // tính là ngày hôm đó đã học và cập nhật chuỗi học tập
    if (isCompleted && !wasAlreadyCompleted) {
      _recordLearningActivity(customDate: completionDate);
    }
    
    final newlyUnlocked = isCompleted ? _checkBadges() : <String>[];
    await _saveProfileInternal();
    notifyListeners();
    return newlyUnlocked;
  }

  Future<void> recordWrongQuestion(String questionId) async {
    if (!_wrongQuestions.contains(questionId)) {
      _wrongQuestions.add(questionId);
      await _saveProfileInternal();
      notifyListeners();
    }
  }

  Future<void> removeWrongQuestion(String questionId) async {
    if (_wrongQuestions.contains(questionId)) {
      _wrongQuestions.remove(questionId);
      await _saveProfileInternal();
      notifyListeners();
    }
  }

  // --- TOP-UP & MEMBERSHIP ---
  
  Future<void> requestTopUp(int vndAmount, int coinAmount) async {
    if (_currentAccount == null) return;
    
    final txCode = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final tx = Transaction(
      id: 'tx_$txCode',
      transactionCode: txCode,
      userId: _currentAccount!.id,
      amount: vndAmount,
      coinAmount: coinAmount,
      status: TransactionStatus.PENDING,
      transferContent: 'SAFEQUEST ${_currentAccount!.id} $txCode',
      createdAt: DateTime.now(),
    );
    
    await DataService().saveTransaction(tx);
    await _loadMyTransactions();
    notifyListeners();
  }

  Future<bool> upgradeMembership(MembershipType newType, int cost) async {
    if (_currentAccount == null) return false;
    
    // Refresh to get latest coin balance
    _currentAccount = await DataService().getAccountById(_currentAccount!.id);
    
    if (_currentAccount!.coinBalance < cost) {
      return false; // Not enough coins
    }
    
    final updatedAccount = _currentAccount!.copyWith(
      coinBalance: _currentAccount!.coinBalance - cost,
      membershipType: newType,
    );
    
    await DataService().saveAccount(updatedAccount);
    _currentAccount = updatedAccount;
    
    notifyListeners();
    return true;
  }
  
  // ADMIN ACTIONS
  Future<void> confirmTransaction(String txId) async {
    if (!isAdmin) return;
    
    _allTransactions = await DataService().getTransactions();
    final index = _allTransactions.indexWhere((t) => t.id == txId);
    if (index == -1) return;
    
    final tx = _allTransactions[index];
    if (tx.status != TransactionStatus.PENDING) return; // Prevent double confirming
    
    final updatedTx = tx.copyWith(status: TransactionStatus.CONFIRMED);
    await DataService().saveTransaction(updatedTx);
    
    // Add coins to user
    final userAcc = await DataService().getAccountById(tx.userId);
    if (userAcc != null) {
      final updatedAcc = userAcc.copyWith(coinBalance: userAcc.coinBalance + tx.coinAmount);
      await DataService().saveAccount(updatedAcc);
    }
    
    _allTransactions = await DataService().getTransactions();
    notifyListeners();
  }

  Future<void> rejectTransaction(String txId, String reason) async {
    if (!isAdmin) return;
    
    _allTransactions = await DataService().getTransactions();
    final index = _allTransactions.indexWhere((t) => t.id == txId);
    if (index == -1) return;
    
    final tx = _allTransactions[index];
    if (tx.status != TransactionStatus.PENDING) return;
    
    final updatedTx = tx.copyWith(
      status: TransactionStatus.REJECTED,
      rejectReason: reason,
    );
    await DataService().saveTransaction(updatedTx);
    
    _allTransactions = await DataService().getTransactions();
    notifyListeners();
  }

  Future<void> adminAdjustCoin(int userId, int amountDiff) async {
    if (!isAdmin) return;
    final acc = await DataService().getAccountById(userId);
    if (acc != null) {
      int newBalance = acc.coinBalance + amountDiff;
      if (newBalance < 0) newBalance = 0;
      await DataService().saveAccount(acc.copyWith(coinBalance: newBalance));
      notifyListeners();
    }
  }

  Future<void> adminSetMembership(int userId, MembershipType type) async {
    if (!isAdmin) return;
    final acc = await DataService().getAccountById(userId);
    if (acc != null) {
      await DataService().saveAccount(acc.copyWith(membershipType: type));
      notifyListeners();
    }
  }

  // --- STREAK & BADGES ---

  void _checkAndUpdateStreak({DateTime? customNow}) {
    if (_profile == null) return;
    
    final now = customNow ?? DateTime.now();
    final lastStudy = _profile!.lastStudyDate;
    
    int currentStreak = _profile!.streak;
    
    if (lastStudy != null) {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastStudy.year, lastStudy.month, lastStudy.day))
          .inDays;
          
      if (difference > 1) {
        // Quá 1 ngày không học -> Chuỗi học tập bị đứt
        currentStreak = 0;
      }
    } else if (_profile!.studyDates.isEmpty) {
      currentStreak = 0;
    }
    
    if (currentStreak != _profile!.streak) {
      _profile = _profile!.copyWith(streak: currentStreak);
      _saveProfileInternal();
      notifyListeners();
    }
  }

  bool _recordLearningActivity({DateTime? customDate}) {
    if (_profile == null) return false;
    
    final now = customDate ?? DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    List<String> updatedStudyDates = List.from(_profile!.studyDates);
    
    if (updatedStudyDates.contains(todayStr)) {
      // Đã hoàn thành ít nhất 1 level mới hôm nay rồi, không tăng thêm chuỗi trong cùng một ngày
      return false;
    }
    
    updatedStudyDates.add(todayStr);
    
    int baseStreak = _profile!.streak;
    if (_profile!.lastStudyDate != null) {
      final daysSinceLastStudy = DateTime(now.year, now.month, now.day)
          .difference(DateTime(_profile!.lastStudyDate!.year, _profile!.lastStudyDate!.month, _profile!.lastStudyDate!.day))
          .inDays;
      if (daysSinceLastStudy > 1) {
        baseStreak = 0;
      }
    } else {
      baseStreak = 0;
    }
    
    int newStreak;
    int longest = _profile!.longestStreak;
    
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    
    if (updatedStudyDates.contains(yesterdayStr) && baseStreak > 0) {
      newStreak = baseStreak + 1;
    } else {
      newStreak = 1;
    }
    
    if (newStreak > longest) {
      longest = newStreak;
    }
    
    _profile = _profile!.copyWith(
      streak: newStreak,
      longestStreak: longest,
      lastStudyDate: now,
      studyDates: updatedStudyDates,
    );
    
    return true; // Streak was successfully recorded and updated for today
  }

  bool recordLearningActivity({DateTime? customDate}) {
    final recorded = _recordLearningActivity(customDate: customDate);
    if (recorded) {
      _saveProfileInternal();
      _checkBadges();
      notifyListeners();
    }
    return recorded;
  }

  List<String> checkBadges() => _checkBadges();

  List<String> _checkBadges() {
    List<String> newlyUnlockedList = [];

    void unlockBadge(String badgeId) {
      if (!_unlockedBadges.contains(badgeId)) {
        _unlockedBadges.add(badgeId);
        newlyUnlockedList.add(badgeId);
        if (!_recentUnlockedBadges.contains(badgeId)) {
          _recentUnlockedBadges.add(badgeId);
        }
      }
    }

    List<String> getQuestionIdsForLevel(String levelId) {
      final allQ = _questions.isNotEmpty ? _questions : MockContentRepository.questions;
      return allQ
          .where((question) => question.levelId == levelId)
          .map((question) => question.id)
          .toList();
    }

    bool hasPerfectLevel(String levelId) {
      final questionIds = getQuestionIdsForLevel(levelId);
      if (questionIds.isEmpty) return false;
      return _progress[levelId] == true &&
          questionIds.every((questionId) => !_wrongQuestions.contains(questionId));
    }

    int countPerfectLevelsInTopic(String topicId) {
      final allL = _levels.isNotEmpty ? _levels : MockContentRepository.levels;
      final topicLevels = allL
          .where((level) => level.topicId == topicId)
          .map((level) => level.id)
          .toList();
      return topicLevels.where(hasPerfectLevel).length;
    }

    bool hasConsecutivePerfectLevels(String topicId, int targetCount) {
      final allL = _levels.isNotEmpty ? _levels : MockContentRepository.levels;
      final levels = allL
          .where((level) => level.topicId == topicId)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      int streak = 0;
      for (final level in levels) {
        if (hasPerfectLevel(level.id)) {
          streak++;
          if (streak >= targetCount) return true;
        } else {
          streak = 0;
        }
      }
      return false;
    }

    bool hasThreeDayStudyStreak() {
      if (_profile == null || _profile!.studyDates.isEmpty) return false;

      final dates = _profile!.studyDates
          .map((date) => DateTime.tryParse(date))
          .whereType<DateTime>()
          .toSet()
          .toList()
        ..sort();

      if (dates.length < 3) return false;

      for (int i = 0; i <= dates.length - 3; i++) {
        final day1 = dates[i];
        final day2 = dates[i + 1];
        final day3 = dates[i + 2];

        if (day2.difference(day1).inDays == 1 && day3.difference(day2).inDays == 1) {
          return true;
        }
      }

      return false;
    }

    // A. Chủ đề An toàn giao thông
    if (_progress['t1_l3'] == true || getCompletedLevelsCount('t1') >= 3) unlockBadge('b1');
    if (hasConsecutivePerfectLevels('t1', 5)) unlockBadge('b2');

    // B. An toàn khi ở nhà
    if (_progress['t2_l3'] == true || getCompletedLevelsCount('t2') >= 3) unlockBadge('b3');
    if (hasConsecutivePerfectLevels('t2', 5)) unlockBadge('b4');

    // C. An toàn ngoài trời
    if (_progress['t3_l3'] == true || getCompletedLevelsCount('t3') >= 3) unlockBadge('b5');
    if (hasConsecutivePerfectLevels('t3', 5)) unlockBadge('b6');

    // D. An toàn với người lạ
    if (_progress['t4_l1'] == true || getCompletedLevelsCount('t4') >= 1) unlockBadge('b7');
    if (hasConsecutivePerfectLevels('t4', 5)) unlockBadge('b8');

    // Các huy hiệu tổng quát
    if (hasPerfectLevel('t1_l1') || hasPerfectLevel('t2_l1') || hasPerfectLevel('t3_l1') || hasPerfectLevel('t4_l1') ||
        hasPerfectLevel('t1_l2') || hasPerfectLevel('t2_l2') || hasPerfectLevel('t3_l2') || hasPerfectLevel('t4_l2') ||
        hasPerfectLevel('t1_l3') || hasPerfectLevel('t2_l3') || hasPerfectLevel('t3_l3') || hasPerfectLevel('t4_l3')) {
      unlockBadge('b9');
    }

    if (hasConsecutivePerfectLevels('t1', 5) || hasConsecutivePerfectLevels('t2', 5) ||
        hasConsecutivePerfectLevels('t3', 5) || hasConsecutivePerfectLevels('t4', 5)) {
      unlockBadge('b10');
    }

    final availableTopics = topics.isNotEmpty ? topics : MockContentRepository.topics;

    // b11: Bộ Óc Siêu Biến - Trả lời đúng toàn bộ câu hỏi của 10 level trong 1 chủ đề bất kỳ
    final has10PerfectLevelsInAnyTopic = availableTopics.any((topic) =>
      countPerfectLevelsInTopic(topic.id) >= 10,
    );
    if (has10PerfectLevelsInAnyTopic) {
      unlockBadge('b11');
    }

    if (hasThreeDayStudyStreak()) unlockBadge('b12');
    if (_profile != null && _profile!.streak >= 7) unlockBadge('b13');
    // b14 (Thợ Săn Thành Tích) đã được gỡ bỏ khỏi hệ thống
    if (_unlockedBadges.length >= 10) unlockBadge('b15');

    // b16: Làm Quen Đa Dạng - Hoàn thành level 1 của 4 chủ đề
    int countTopicsWithLevel1 = 0;
    for (final topic in availableTopics) {
      if (_progress['${topic.id}_l1'] == true || getCompletedLevelsCount(topic.id) >= 1) {
        countTopicsWithLevel1++;
      }
    }
    if (countTopicsWithLevel1 >= 4) {
      unlockBadge('b16');
    }

    // b17: Làm Nhiều Quen Cách - Hoàn thành level 5 của 4 chủ đề
    int countTopicsWithLevel5 = 0;
    for (final topic in availableTopics) {
      if (_progress['${topic.id}_l5'] == true || getCompletedLevelsCount(topic.id) >= 5) {
        countTopicsWithLevel5++;
      }
    }
    if (countTopicsWithLevel5 >= 4) {
      unlockBadge('b17');
    }

    // b18: Đi Nhiều Nhớ Đường - Hoàn thành level 7 của 1 chủ đề bất kì
    final hasCompletedLevel7AnyTopic = availableTopics.any((topic) =>
      _progress['${topic.id}_l7'] == true || getCompletedLevelsCount(topic.id) >= 7,
    );
    if (hasCompletedLevel7AnyTopic) {
      unlockBadge('b18');
    }

    // b19: Tập Sự Sơ Cấp - Đạt 300 điểm học tập
    if ((_profile?.points ?? 0) >= 300) {
      unlockBadge('b19');
    }

    // b20: Tập Sự Trung Cấp - Đạt 1000 điểm học tập
    if ((_profile?.points ?? 0) >= 1000) {
      unlockBadge('b20');
    }

    if (newlyUnlockedList.isNotEmpty) {
      _saveProfileInternal();
      notifyListeners();
    }

    return newlyUnlockedList;
  }

  // --- HELPERS ---
  
  Map<String, dynamic> getContinueLearningContext() {
    final availableTopics = topics.isNotEmpty ? topics : MockContentRepository.topics;
    final allLevels = _levels.isNotEmpty ? _levels : MockContentRepository.levels;

    if (availableTopics.isEmpty) return {};

    Topic? bestTopic;
    Level? bestLevel;
    int maxLevelOrder = -1;
    int maxCompletedCount = -1;
    int maxLatestIndex = -1;

    final historyList = _profile?.completedLevels ?? _progress.keys.toList();

    // Check if there are any topics that are not fully completed yet
    bool hasAnyIncompleteTopic = false;
    for (var topic in availableTopics) {
      final topicLevels = allLevels.where((l) => l.topicId == topic.id).toList();
      if (topicLevels.isEmpty) continue;
      final completed = topicLevels.where((l) => isLevelCompleted(l.id)).length;
      if (completed < topicLevels.length) {
        hasAnyIncompleteTopic = true;
        break;
      }
    }

    for (var topic in availableTopics) {
      final topicLevels = allLevels.where((l) => l.topicId == topic.id).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (topicLevels.isEmpty) continue;

      final completedLevels = topicLevels.where((l) => isLevelCompleted(l.id)).toList();
      final completedCount = completedLevels.length;
      final isTopicFullyCompleted = completedCount == topicLevels.length;

      // If there are other incomplete topics, don't prioritize 100% completed topics
      if (hasAnyIncompleteTopic && isTopicFullyCompleted) {
        continue;
      }

      // Find the highest level of this topic to display (the current level to learn)
      Level currentLevel;
      if (!isTopicFullyCompleted) {
        currentLevel = topicLevels.firstWhere(
          (l) => !isLevelCompleted(l.id),
          orElse: () => topicLevels.last,
        );
      } else {
        currentLevel = topicLevels.last;
      }

      final levelOrder = currentLevel.order;

      // Find latest completion index for tie breaking
      int latestIndex = -1;
      for (var l in completedLevels) {
        final idx = historyList.lastIndexOf(l.id);
        if (idx > latestIndex) {
          latestIndex = idx;
        }
      }

      // Compare to find the topic with the highest level
      bool isBetter = false;
      if (bestTopic == null) {
        isBetter = true;
      } else if (levelOrder > maxLevelOrder) {
        isBetter = true;
      } else if (levelOrder == maxLevelOrder) {
        if (completedCount > maxCompletedCount) {
          isBetter = true;
        } else if (completedCount == maxCompletedCount) {
          if (latestIndex > maxLatestIndex) {
            isBetter = true;
          }
        }
      }

      if (isBetter) {
        bestTopic = topic;
        bestLevel = currentLevel;
        maxLevelOrder = levelOrder;
        maxCompletedCount = completedCount;
        maxLatestIndex = latestIndex;
      }
    }

    // Fallback if all topics were skipped
    if (bestTopic == null) {
      final firstTopic = availableTopics.first;
      final topicLevels = allLevels.where((l) => l.topicId == firstTopic.id).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      bestTopic = firstTopic;
      bestLevel = topicLevels.isNotEmpty ? topicLevels.last : null;
    }

    if (bestTopic != null && bestLevel != null) {
      return {
        'topic': bestTopic,
        'level': bestLevel,
      };
    }

    return {};
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}

