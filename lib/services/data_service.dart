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
  }

  // --- ACCOUNTS ---
  Future<List<Account>> getAccounts() async {
    // 1. Try to sync latest accounts from Firestore online
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!.collection('accounts').get().timeout(const Duration(seconds: 4));
        if (snapshot.docs.isNotEmpty) {
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

          final localList = _prefs.getStringList('accounts') ?? [];
          final localAccounts = localList.map((e) => Account.fromJson(e)).toList();
          
          for (var remote in remoteAccounts) {
            final idx = localAccounts.indexWhere((l) => 
              l.id == remote.id || l.username.trim().toLowerCase() == remote.username.trim().toLowerCase()
            );
            if (idx >= 0) {
              localAccounts[idx] = remote;
            } else {
              localAccounts.add(remote);
            }
          }

          // Deduplicate localAccounts by username (case-insensitive)
          final unique = <String, Account>{};
          for (var acc in localAccounts) {
            unique[acc.username.trim().toLowerCase()] = acc;
          }
          final cleanList = unique.values.toList();
          await _prefs.setStringList('accounts', cleanList.map((e) => e.toJson()).toList());
          return cleanList;
        }
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
    try {
      if (_auth != null && _firestore != null) {
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
      }
    } catch (e) {
      debugPrint('Online authenticate notice: $e');
    }

    // 3. Fallback to local accounts
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
        if (snap.docs.isNotEmpty) {
          final remoteList = snap.docs.map((d) => Transaction.fromMap(d.data())).toList();
          await _prefs.setStringList('transactions', remoteList.map((e) => e.toJson()).toList());
          return remoteList;
        }
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
  }

  // --- LEVELS ---
  Future<List<Level>> getLevels() async {
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
  }

  // --- QUESTIONS ---
  Future<List<Question>> getQuestions() async {
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
  }
  
  Future<void> deleteQuestion(String id) async {
    final questions = await getQuestions();
    questions.removeWhere((e) => e.id == id);
    await _prefs.setStringList('questions', questions.map((e) => e.toJson()).toList());
  }

  // --- CHILD PROFILES ---
  Future<List<ChildProfile>> getChildProfiles() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('childProfiles').get().timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          final remoteProfiles = snap.docs.map((d) => ChildProfile.fromMap(d.data())).toList();
          final localList = _prefs.getStringList('childProfiles') ?? [];
          final localProfiles = localList.map((e) => ChildProfile.fromJson(e)).toList();

          for (var remote in remoteProfiles) {
            final idx = localProfiles.indexWhere((l) => l.accountId == remote.accountId || l.id == remote.id);
            if (idx >= 0) {
              localProfiles[idx] = remote;
            } else {
              localProfiles.add(remote);
            }
          }
          await _prefs.setStringList('childProfiles', localProfiles.map((e) => e.toJson()).toList());
          return localProfiles;
        }
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
}