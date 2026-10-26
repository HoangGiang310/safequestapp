import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/models.dart';
import '../data/mock_data.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late SharedPreferences _prefs;

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String _formatEmail(String username) {
    final clean = username.trim().toLowerCase();
    if (clean.contains('@')) return clean;
    return '$clean@safequest.app';
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedInitialData();
  }

  Future<void> _seedInitialData() async {
    if (!_prefs.containsKey('accounts')) {
      final admin = Account(id: 1000, username: 'admin', password: '123', role: Role.ADMIN, createdAt: DateTime.now());
      await saveAccount(admin);
    }

    final topics = MockContentRepository.topics.map((e) => e.toJson()).toList();
    final levels = MockContentRepository.levels.map((e) => e.toJson()).toList();
    final questions = MockContentRepository.questions.map((e) => e.toJson()).toList();

    final savedTopics = _prefs.getStringList('topics');
    if (savedTopics == null || savedTopics.isEmpty) {
      await _prefs.setStringList('topics', topics);
    }

    final savedLevels = _prefs.getStringList('levels');
    if (savedLevels == null || savedLevels.isEmpty) {
      await _prefs.setStringList('levels', levels);
    }

    final savedQuestions = _prefs.getStringList('questions');
    if (savedQuestions == null || savedQuestions.isEmpty) {
      await _prefs.setStringList('questions', questions);
    }

    final savedLessonVideos = _prefs.getStringList('lesson_videos');
    if (savedLessonVideos == null || savedLessonVideos.isEmpty) {
      await _prefs.setStringList('lesson_videos', MockContentRepository.lessonVideos.map((e) => e.toJson()).toList());
    }

    // Seed initial content to Firestore if Firestore is active and collection is empty
    try {
      if (_firestore != null) {
        final qCheck = await _firestore!.collection('questions').limit(1).get().timeout(const Duration(seconds: 4));
        if (qCheck.docs.isEmpty) {
          debugPrint('Seeding default topics, levels, and questions to Firestore...');
          final batch = _firestore!.batch();
          for (var t in MockContentRepository.topics) {
            batch.set(_firestore!.collection('topics').doc(t.id), t.toMap());
          }
          for (var l in MockContentRepository.levels) {
            batch.set(_firestore!.collection('levels').doc(l.id), l.toMap());
          }
          for (var q in MockContentRepository.questions) {
            batch.set(_firestore!.collection('questions').doc(q.id), q.toMap());
          }
          await batch.commit().timeout(const Duration(seconds: 8));
          debugPrint('Successfully seeded initial content to Firestore');
        }

        final vCheck = await _firestore!.collection('lesson_videos').limit(1).get().timeout(const Duration(seconds: 4));
        if (vCheck.docs.isEmpty) {
          debugPrint('Seeding default lesson videos to Firestore...');
          final vBatch = _firestore!.batch();
          for (var v in MockContentRepository.lessonVideos) {
            vBatch.set(_firestore!.collection('lesson_videos').doc(v.id), v.toMap());
          }
          await vBatch.commit().timeout(const Duration(seconds: 8));
          debugPrint('Successfully seeded lesson videos to Firestore');
        }
      }
    } catch (e) {
      debugPrint('Firestore initial content seed notice: $e');
    }
  }

  // --- ACCOUNTS ---
  Future<List<Account>> getAccounts() async {
    // 1. Try to sync latest accounts from Firestore online
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!.collection('accounts').get().timeout(const Duration(seconds: 4));
        final remoteAccounts = <Account>[];
        final seenUsernames = <String, DocumentReference>{};

        for (var doc in snapshot.docs) {
          try {
            final acc = Account.fromMap(doc.data());
            final key = acc.username.trim().toLowerCase();
            if (seenUsernames.containsKey(key)) {
              // Duplicate account in Firestore! Clean up the extra document
              debugPrint('Removing duplicate remote account doc: ${doc.id}');
              doc.reference.delete();
            } else {
              seenUsernames[key] = doc.reference;
              remoteAccounts.add(acc);
            }
          } catch (e) {
            debugPrint('Error parsing account doc: $e');
          }
        }

        // Ensure default admin account exists
        if (!remoteAccounts.any((a) => a.username.trim().toLowerCase() == 'admin')) {
          remoteAccounts.insert(0, Account(
            id: 1000,
            username: 'admin',
            password: '123',
            role: Role.ADMIN,
            createdAt: DateTime.now(),
          ));
        }

        // Source of truth is Firestore: update local cache with clean remote accounts
        await _prefs.setStringList('accounts', remoteAccounts.map((e) => e.toJson()).toList());
        return remoteAccounts;
      }
    } catch (e) {
      debugPrint('Firestore getAccounts notice / fallback to local: $e');
    }

    final list = _prefs.getStringList('accounts') ?? [];
    final accounts = list.map((e) => Account.fromJson(e)).toList();
    final unique = <String, Account>{};
    for (var acc in accounts) {
      unique[acc.username.trim().toLowerCase()] = acc;
    }
    return unique.values.toList();
  }
  
  Future<Account?> getAccountById(int id) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('accounts').doc(id.toString()).get().timeout(const Duration(seconds: 3));
        if (doc.exists && doc.data() != null) {
          final acc = Account.fromMap(doc.data()!);
          await _saveAccountLocally(acc);
          return acc;
        }
      }
    } catch (e) {
      debugPrint('Firestore getAccountById notice: $e');
    }

    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAccountLocally(Account account) async {
    final list = _prefs.getStringList('accounts') ?? [];
    final accounts = list.map((e) => Account.fromJson(e)).toList();
    final index = accounts.indexWhere((e) => 
      e.id == account.id || e.username.trim().toLowerCase() == account.username.trim().toLowerCase()
    );
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await _prefs.setStringList('accounts', accounts.map((e) => e.toJson()).toList());
  }

  Future<Account> saveAccount(Account account) async {
    await _saveAccountLocally(account);

    // Sync online to Firestore
    try {
      if (_firestore != null) {
        await _firestore!
            .collection('accounts')
            .doc(account.id.toString())
            .set(account.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveAccount notice: $e');
    }

    return account;
  }
  
  Future<Account?> authenticate(String username, String password) async {
    final cleanUsername = username.trim();
    final lowerUser = cleanUsername.toLowerCase();

    // 1. Admin local/special check
    if (cleanUsername == 'admin' && password == '123') {
      final accounts = await getAccounts();
      final admin = accounts.firstWhere(
        (e) => e.username == 'admin',
        orElse: () => Account(id: 1000, username: 'admin', password: '123', role: Role.ADMIN, createdAt: DateTime.now()),
      );
      return admin;
    }

    // 2. Try Firebase Auth + Firestore
    if (_auth != null && _firestore != null) {
      try {
        final email = _formatEmail(cleanUsername);
        final safePass = password.length < 6 ? password.padRight(6, '0') : password;
        
        try {
          await _auth!.signInWithEmailAndPassword(email: email, password: safePass).timeout(const Duration(seconds: 5));
        } catch (authErr) {
          debugPrint('Firebase signIn notice: $authErr');
        }

        // Get all accounts from Firestore and match case-insensitively
        final snap = await _firestore!.collection('accounts').get().timeout(const Duration(seconds: 4));
        for (var doc in snap.docs) {
          final acc = Account.fromMap(doc.data());
          if (acc.username.trim().toLowerCase() == lowerUser && acc.password == password) {
            await _saveAccountLocally(acc);
            return acc;
          }
        }
        // If Firestore is reachable and user is not in Firestore -> Reject!
        return null;
      } catch (e) {
        debugPrint('Online authenticate notice / fallback: $e');
      }
    }

    // 3. Fallback to local accounts ONLY if Firestore is unreachable
    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((e) => e.username.trim().toLowerCase() == lowerUser && e.password == password);
    } catch (e) {
      return null;
    }
  }

  Future<Account?> registerAccount(String username, String password) async {
    final cleanUsername = username.trim();
    final lowerUser = cleanUsername.toLowerCase();

    // 1. Check if username exists locally
    final accounts = await getAccounts();
    if (accounts.any((e) => e.username.trim().toLowerCase() == lowerUser)) {
      return null;
    }

    // 2. Check if username exists online in Firestore
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('accounts').get().timeout(const Duration(seconds: 4));
        for (var doc in snap.docs) {
          final u = (doc.data()['username'] as String? ?? '').trim().toLowerCase();
          if (u == lowerUser) {
            return null; // Username already taken
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore check existing user notice: $e');
    }

    // 3. Register user with Firebase Auth
    try {
      if (_auth != null) {
        final email = _formatEmail(cleanUsername);
        final safePass = password.length < 6 ? password.padRight(6, '0') : password;
        await _auth!.createUserWithEmailAndPassword(email: email, password: safePass).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('FirebaseAuth createUser notice: $e');
      // If Firebase Auth fails (e.g. email already in use), reject registration!
      return null;
    }

    // 4. Generate unique ID & Save to Firestore and local
    final newId = await generateNewAccountId();
    final newAccount = Account(
      id: newId,
      username: cleanUsername,
      password: password,
      role: Role.CUSTOMER,
      createdAt: DateTime.now(),
    );

    await saveAccount(newAccount);
    return newAccount;
  }
  
  Future<bool> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final accounts = await getAccounts();

    final idx = accounts.indexWhere(
      (a) => a.username.trim().toLowerCase() == cleanUsername && a.password == oldPassword,
    );

    if (idx < 0) {
      return false;
    }

    final targetAccount = accounts[idx];
    final updatedAccount = targetAccount.copyWith(password: newPassword);

    await saveAccount(updatedAccount);

    // Update Firebase Auth password if current user matches
    try {
      if (_auth != null && _auth!.currentUser != null) {
        final currentEmail = _auth!.currentUser!.email?.toLowerCase();
        final targetEmail = _formatEmail(cleanUsername).toLowerCase();
        if (currentEmail == targetEmail) {
          await _auth!.currentUser!.updatePassword(newPassword);
        }
      }
    } catch (e) {
      debugPrint('FirebaseAuth updatePassword notice: $e');
    }

    return true;
  }

  Future<int> generateNewAccountId() async {
    int maxId = 1000;
    try {
      final accounts = await getAccounts();
      for (var acc in accounts) {
        if (acc.id > maxId) maxId = acc.id;
      }
    } catch (_) {}
    return maxId + 1;
  }

  // --- TRANSACTIONS ---
  Future<List<Transaction>> getTransactions() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('transactions').get().timeout(const Duration(seconds: 4));
        final remoteList = snap.docs.map((d) => Transaction.fromMap(d.data())).toList();
        await _prefs.setStringList('transactions', remoteList.map((e) => e.toJson()).toList());
        return remoteList;
      }
    } catch (e) {
      debugPrint('Firestore getTransactions notice: $e');
    }

    final list = _prefs.getStringList('transactions') ?? [];
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<List<Transaction>> getTransactionsByUserId(int userId) async {
    final all = await getTransactions();
    return all.where((t) => t.userId == userId).toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((e) => e.id == transaction.id);
    if (index >= 0) {
      transactions[index] = transaction;
    } else {
      transactions.add(transaction);
    }
    await _prefs.setStringList('transactions', transactions.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('transactions')
            .doc(transaction.id.toString())
            .set(transaction.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveTransaction notice: $e');
    }
  }

  // --- TOPICS ---
  Future<List<Topic>> getTopics() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('topics').get().timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteTopics = snap.docs.map((d) => Topic.fromMap(d.data())).toList();
          await _prefs.setStringList('topics', remoteTopics.map((e) => e.toJson()).toList());
          return remoteTopics;
        }
      }
    } catch (e) {
      debugPrint('Firestore getTopics fallback: $e');
    }

    final list = _prefs.getStringList('topics') ?? [];
    return list.map((e) => Topic.fromJson(e)).toList();
  }

  Future<void> saveTopic(Topic topic) async {
    final topics = await getTopics();
    final index = topics.indexWhere((e) => e.id == topic.id);
    if (index >= 0) {
      topics[index] = topic;
    } else {
      topics.add(topic);
    }
    await _prefs.setStringList('topics', topics.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('topics')
            .doc(topic.id)
            .set(topic.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveTopic notice: $e');
    }
  }

  // --- LEVELS ---
  Future<List<Level>> getLevels() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('levels').get().timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteLevels = snap.docs.map((d) => Level.fromMap(d.data())).toList();
          await _prefs.setStringList('levels', remoteLevels.map((e) => e.toJson()).toList());
          return remoteLevels;
        }
      }
    } catch (e) {
      debugPrint('Firestore getLevels fallback: $e');
    }

    final list = _prefs.getStringList('levels') ?? [];
    return list.map((e) => Level.fromJson(e)).toList();
  }

  Future<void> saveLevel(Level level) async {
    final levels = await getLevels();
    final index = levels.indexWhere((e) => e.id == level.id);
    if (index >= 0) {
      levels[index] = level;
    } else {
      levels.add(level);
    }
    await _prefs.setStringList('levels', levels.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('levels')
            .doc(level.id)
            .set(level.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveLevel notice: $e');
    }
  }

  // --- QUESTIONS ---
  Future<List<Question>> getQuestions() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('questions').get().timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteQuestions = snap.docs.map((d) => Question.fromMap(d.data())).toList();
          await _prefs.setStringList('questions', remoteQuestions.map((e) => e.toJson()).toList());
          return remoteQuestions;
        }
      }
    } catch (e) {
      debugPrint('Firestore getQuestions fallback: $e');
    }

    final list = _prefs.getStringList('questions') ?? [];
    return list.map((e) => Question.fromJson(e)).toList();
  }

  Future<void> saveQuestion(Question question) async {
    final questions = await getQuestions();
    final index = questions.indexWhere((e) => e.id == question.id);
    if (index >= 0) {
      questions[index] = question;
    } else {
      questions.add(question);
    }
    await _prefs.setStringList('questions', questions.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('questions')
            .doc(question.id)
            .set(question.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveQuestion notice: $e');
    }
  }
  
  Future<void> deleteQuestion(String id) async {
    final questions = await getQuestions();
    questions.removeWhere((e) => e.id == id);
    await _prefs.setStringList('questions', questions.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('questions')
            .doc(id)
            .delete()
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore deleteQuestion notice: $e');
    }
  }

  // --- LESSON VIDEOS ---
  Future<List<LessonVideo>> getLessonVideos() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('lesson_videos').get().timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteVideos = snap.docs.map((d) => LessonVideo.fromMap(d.data())).toList();
          remoteVideos.sort((a, b) => a.order.compareTo(b.order));
          await _prefs.setStringList('lesson_videos', remoteVideos.map((e) => e.toJson()).toList());
          return remoteVideos;
        }
      }
    } catch (e) {
      debugPrint('Firestore getLessonVideos fallback: $e');
    }

    final list = _prefs.getStringList('lesson_videos') ?? [];
    if (list.isNotEmpty) {
      final cached = list.map((e) => LessonVideo.fromJson(e)).toList();
      cached.sort((a, b) => a.order.compareTo(b.order));
      return cached;
    }

    return MockContentRepository.lessonVideos;
  }

  Future<void> saveLessonVideo(LessonVideo video) async {
    final videos = await getLessonVideos();
    final index = videos.indexWhere((e) => e.id == video.id);
    if (index >= 0) {
      videos[index] = video;
    } else {
      videos.add(video);
    }
    await _prefs.setStringList('lesson_videos', videos.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('lesson_videos')
            .doc(video.id)
            .set(video.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveLessonVideo notice: $e');
    }
  }

  // --- CHILD PROFILES ---
  Future<List<ChildProfile>> getChildProfiles() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('childProfiles').get().timeout(const Duration(seconds: 4));
        final remoteProfiles = snap.docs.map((d) => ChildProfile.fromMap(d.data())).toList();
        await _prefs.setStringList('childProfiles', remoteProfiles.map((e) => e.toJson()).toList());
        return remoteProfiles;
      }
    } catch (e) {
      debugPrint('Firestore getChildProfiles notice / fallback: $e');
    }

    final list = _prefs.getStringList('childProfiles') ?? [];
    return list.map((e) => ChildProfile.fromJson(e)).toList();
  }
  
  Future<ChildProfile?> getChildProfileByAccountId(int accountId) async {
    // 1. Fetch from Firestore online so Device B gets the latest profile
    try {
      if (_firestore != null) {
        final doc = await _firestore!
            .collection('childProfiles')
            .doc(accountId.toString())
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          final profile = ChildProfile.fromMap(doc.data()!);
          await _saveChildProfileLocally(profile);
          return profile;
        }
      }
    } catch (e) {
      debugPrint('Firestore getChildProfile notice: $e');
    }

    final profiles = await getChildProfiles();
    try {
      return profiles.firstWhere((e) => e.accountId == accountId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveChildProfileLocally(ChildProfile profile) async {
    final profiles = await getChildProfiles();
    final index = profiles.indexWhere((e) => e.id == profile.id || e.accountId == profile.accountId);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await _prefs.setStringList('childProfiles', profiles.map((e) => e.toJson()).toList());
  }

  Future<void> saveChildProfile(ChildProfile profile) async {
    await _saveChildProfileLocally(profile);

    // Sync online to Firestore
    try {
      if (_firestore != null) {
        await _firestore!
            .collection('childProfiles')
            .doc(profile.accountId.toString())
            .set(profile.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveChildProfile notice: $e');
    }
  }

  // --- FEEDBACKS ---
  Future<List<UserFeedback>> getFeedbacks() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!
            .collection('feedbacks')
            .get()
            .timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteFeedbacks = snap.docs.map((d) => UserFeedback.fromMap(d.data())).toList();
          final localList = _prefs.getStringList('feedbacks') ?? [];
          final localFeedbacks = localList.map((e) => UserFeedback.fromJson(e)).toList();

          for (var remote in remoteFeedbacks) {
            final idx = localFeedbacks.indexWhere((l) => l.id == remote.id);
            if (idx >= 0) {
              localFeedbacks[idx] = remote;
            } else {
              localFeedbacks.add(remote);
            }
          }
          await _prefs.setStringList('feedbacks', localFeedbacks.map((e) => e.toJson()).toList());
          localFeedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return localFeedbacks;
        }
      }
    } catch (e) {
      debugPrint('Firestore getFeedbacks notice / fallback: $e');
    }

    final list = _prefs.getStringList('feedbacks') ?? [];
    final feedbacks = list.map((e) => UserFeedback.fromJson(e)).toList();
    feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return feedbacks;
  }

  Future<bool> saveFeedback(UserFeedback feedback) async {
    final list = _prefs.getStringList('feedbacks') ?? [];
    final feedbacks = list.map((e) => UserFeedback.fromJson(e)).toList();
    final idx = feedbacks.indexWhere((f) => f.id == feedback.id);
    if (idx >= 0) {
      feedbacks[idx] = feedback;
    } else {
      feedbacks.insert(0, feedback);
    }
    await _prefs.setStringList('feedbacks', feedbacks.map((e) => e.toJson()).toList());

    try {
      if (_firestore != null) {
        await _firestore!
            .collection('feedbacks')
            .doc(feedback.id)
            .set(feedback.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
      }
    } catch (e) {
      debugPrint('Firestore saveFeedback notice: $e');
    }

    return true;
  }
}