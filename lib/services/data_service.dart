import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late SharedPreferences _prefs;

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
    final list = _prefs.getStringList('accounts') ?? [];
    return list.map((e) => Account.fromJson(e)).toList();
  }
  
  Future<Account?> getAccountById(int id) async {
    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Account> saveAccount(Account account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((e) => e.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await _prefs.setStringList('accounts', accounts.map((e) => e.toJson()).toList());
    return account;
  }
  
  Future<Account?> authenticate(String username, String password) async {
    final accounts = await getAccounts();
    try {
      return accounts.firstWhere((e) => e.username == username && e.password == password);
    } catch (e) {
      return null;
    }
  }
  
  Future<int> generateNewAccountId() async {
    final accounts = await getAccounts();
    int maxId = 1000;
    for (var acc in accounts) {
      if (acc.id > maxId) maxId = acc.id;
    }
    return maxId + 1;
  }

  // --- TRANSACTIONS ---
  Future<List<Transaction>> getTransactions() async {
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
    final list = _prefs.getStringList('childProfiles') ?? [];
    return list.map((e) => ChildProfile.fromJson(e)).toList();
  }
  
  Future<ChildProfile?> getChildProfileByAccountId(int accountId) async {
    final profiles = await getChildProfiles();
    try {
      return profiles.firstWhere((e) => e.accountId == accountId);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveChildProfile(ChildProfile profile) async {
    final profiles = await getChildProfiles();
    final index = profiles.indexWhere((e) => e.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await _prefs.setStringList('childProfiles', profiles.map((e) => e.toJson()).toList());
  }
}