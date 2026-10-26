import 'dart:convert';

enum QuestionType { singleChoice, multipleChoice, dialogue }
enum Role { ADMIN, CUSTOMER }
enum MembershipType { FREE, VIP, PREMIUM }
enum TransactionStatus { PENDING, CONFIRMED, REJECTED }

class Account {
  final int id;
  final String username;
  final String password;
  final Role role;
  final int coinBalance;
  final MembershipType membershipType;
  final DateTime createdAt;
  final String? currentSessionId;

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.coinBalance = 0,
    this.membershipType = MembershipType.FREE,
    required this.createdAt,
    this.currentSessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.index,
      'coinBalance': coinBalance,
      'membershipType': membershipType.index,
      'createdAt': createdAt.toIso8601String(),
      'currentSessionId': currentSessionId,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      final raw = map['createdAt'];
      if (raw == null) {
        parsedDate = DateTime.now();
      } else if (raw is String) {
        parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
      } else {
        try {
          parsedDate = (raw as dynamic).toDate();
        } catch (_) {
          parsedDate = DateTime.now();
        }
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final roleVal = map['role'];
    final roleIndex = (roleVal is int && roleVal >= 0 && roleVal < Role.values.length) ? roleVal : 1;

    final membershipVal = map['membershipType'];
    final membershipIndex = (membershipVal is int && membershipVal >= 0 && membershipVal < MembershipType.values.length) ? membershipVal : 0;

    return Account(
      id: map['id']?.toInt() ?? 0,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: Role.values[roleIndex],
      coinBalance: map['coinBalance']?.toInt() ?? 0,
      membershipType: MembershipType.values[membershipIndex],
      createdAt: parsedDate,
      currentSessionId: map['currentSessionId'] as String?,
    );
  }

  Account copyWith({
    int? id,
    String? username,
    String? password,
    Role? role,
    int? coinBalance,
    MembershipType? membershipType,
    DateTime? createdAt,
    String? currentSessionId,
  }) {
    return Account(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      coinBalance: coinBalance ?? this.coinBalance,
      membershipType: membershipType ?? this.membershipType,
      createdAt: createdAt ?? this.createdAt,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }

  String toJson() => json.encode(toMap());
  factory Account.fromJson(String source) => Account.fromMap(json.decode(source));
}

class Transaction {
  final String id;
  final String transactionCode;
  final int userId;
  final int amount; // VNĐ
  final int coinAmount;
  final TransactionStatus status;
  final String transferContent;
  final String? rejectReason;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.transactionCode,
    required this.userId,
    required this.amount,
    required this.coinAmount,
    this.status = TransactionStatus.PENDING,
    required this.transferContent,
    this.rejectReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionCode': transactionCode,
      'userId': userId,
      'amount': amount,
      'coinAmount': coinAmount,
      'status': status.index,
      'transferContent': transferContent,
      'rejectReason': rejectReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      final raw = map['createdAt'];
      if (raw == null) {
        parsedDate = DateTime.now();
      } else if (raw is String) {
        parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
      } else {
        try {
          parsedDate = (raw as dynamic).toDate();
        } catch (_) {
          parsedDate = DateTime.now();
        }
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final statusVal = map['status'];
    final statusIndex = (statusVal is int && statusVal >= 0 && statusVal < TransactionStatus.values.length) ? statusVal : 0;

    return Transaction(
      id: map['id'] ?? '',
      transactionCode: map['transactionCode'] ?? '',
      userId: map['userId']?.toInt() ?? 0,
      amount: map['amount']?.toInt() ?? 0,
      coinAmount: map['coinAmount']?.toInt() ?? 0,
      status: TransactionStatus.values[statusIndex],
      transferContent: map['transferContent'] ?? '',
      rejectReason: map['rejectReason'],
      createdAt: parsedDate,
    );
  }
  
  Transaction copyWith({
    String? id,
    String? transactionCode,
    int? userId,
    int? amount,
    int? coinAmount,
    TransactionStatus? status,
    String? transferContent,
    String? rejectReason,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionCode: transactionCode ?? this.transactionCode,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      coinAmount: coinAmount ?? this.coinAmount,
      status: status ?? this.status,
      transferContent: transferContent ?? this.transferContent,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String toJson() => json.encode(toMap());
  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));
}

class Topic {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int colorValue;
  final int totalLevels;
  final bool isActive;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.totalLevels,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'colorValue': colorValue,
      'totalLevels': totalLevels,
      'isActive': isActive,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      colorValue: map['colorValue']?.toInt() ?? 0,
      totalLevels: map['totalLevels']?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? colorValue,
    int? totalLevels,
    bool? isActive,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      totalLevels: totalLevels ?? this.totalLevels,
      isActive: isActive ?? this.isActive,
    );
  }

  String toJson() => json.encode(toMap());
  factory Topic.fromJson(String source) => Topic.fromMap(json.decode(source));
}

class Level {
  final String id;
  final String topicId;
  final String title;
  final String description;
  final int order;

  Level({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'] ?? '',
      topicId: map['topicId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order']?.toInt() ?? 0,
    );
  }

  Level copyWith({
    String? id,
    String? topicId,
    String? title,
    String? description,
    int? order,
  }) {
    return Level(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }

  String toJson() => json.encode(toMap());
  factory Level.fromJson(String source) => Level.fromMap(json.decode(source));
}

class Question {
  final String id;
  final String levelId;
  final QuestionType type;
  final String question;
  final String? image;
  final String? audio;
  final List<String> options;
  final List<int> correctAnswers;
  final String hint;
  final String explanation;
  final String? characterDialogue;
  final bool isActive;

  Question({
    required this.id,
    required this.levelId,
    required this.type,
    required this.question,
    this.image,
    this.audio,
    required this.options,
    required this.correctAnswers,
    required this.hint,
    required this.explanation,
    this.characterDialogue,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'levelId': levelId,
      'type': type.index,
      'question': question,
      'image': image,
      'audio': audio,
      'options': options,
      'correctAnswers': correctAnswers,
      'hint': hint,
      'explanation': explanation,
      'characterDialogue': characterDialogue,
      'isActive': isActive,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    final typeVal = map['type'];
    final typeIndex = (typeVal is int && typeVal >= 0 && typeVal < QuestionType.values.length) ? typeVal : 0;

    final rawAnswers = map['correctAnswers'];
    final List<int> parsedAnswers = (rawAnswers is List)
        ? rawAnswers.map((e) => (e is num) ? e.toInt() : int.tryParse(e.toString()) ?? 0).toList()
        : [];

    final rawOptions = map['options'];
    final List<String> parsedOptions = (rawOptions is List)
        ? rawOptions.map((e) => e.toString()).toList()
        : [];

    return Question(
      id: map['id'] ?? '',
      levelId: map['levelId'] ?? '',
      type: QuestionType.values[typeIndex],
      question: map['question'] ?? '',
      image: map['image'],
      audio: map['audio'],
      options: parsedOptions,
      correctAnswers: parsedAnswers,
      hint: map['hint'] ?? '',
      explanation: map['explanation'] ?? '',
      characterDialogue: map['characterDialogue'],
      isActive: map['isActive'] ?? true,
    );
  }

  Question copyWith({
    String? id,
    String? levelId,
    QuestionType? type,
    String? question,
    String? image,
    String? audio,
    List<String>? options,
    List<int>? correctAnswers,
    String? hint,
    String? explanation,
    String? characterDialogue,
    bool? isActive,
  }) {
    return Question(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      type: type ?? this.type,
      question: question ?? this.question,
      image: image ?? this.image,
      audio: audio ?? this.audio,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      hint: hint ?? this.hint,
      explanation: explanation ?? this.explanation,
      characterDialogue: characterDialogue ?? this.characterDialogue,
      isActive: isActive ?? this.isActive,
    );
  }

  String toJson() => json.encode(toMap());
  factory Question.fromJson(String source) => Question.fromMap(json.decode(source));
}

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String icon;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class ChildProfile {
  final String id;
  final int accountId;
  final String name;
  final int age;
  final String avatar;
  final int points;
  final int streak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final List<String> studyDates; // Format: "YYYY-MM-DD"
  final List<String> unlockedBadges;
  final List<String> completedLevels;
  final List<String> wrongQuestions;
  final String? lastCheckInDate; // Format: "YYYY-MM-DD"

  ChildProfile({
    required this.id,
    required this.accountId,
    required this.name,
    required this.age,
    required this.avatar,
    required this.points,
    required this.streak,
    required this.longestStreak,
    this.lastStudyDate,
    required this.studyDates,
    required this.unlockedBadges,
    required this.completedLevels,
    required this.wrongQuestions,
    this.lastCheckInDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'name': name,
      'age': age,
      'avatar': avatar,
      'points': points,
      'streak': streak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'studyDates': studyDates,
      'unlockedBadges': unlockedBadges,
      'completedLevels': completedLevels,
      'wrongQuestions': wrongQuestions,
      'lastCheckInDate': lastCheckInDate,
    };
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] ?? '',
      accountId: map['accountId']?.toInt() ?? 0,
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      avatar: map['avatar'] ?? '',
      points: map['points']?.toInt() ?? 0,
      streak: map['streak']?.toInt() ?? 0,
      longestStreak: map['longestStreak']?.toInt() ?? 0,
      lastStudyDate: map['lastStudyDate'] != null ? DateTime.tryParse(map['lastStudyDate'].toString()) : null,
      studyDates: List<String>.from(map['studyDates'] ?? []),
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      completedLevels: List<String>.from(map['completedLevels'] ?? []),
      wrongQuestions: List<String>.from(map['wrongQuestions'] ?? []),
      lastCheckInDate: map['lastCheckInDate'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChildProfile.fromJson(String source) => ChildProfile.fromMap(json.decode(source));

  ChildProfile copyWith({
    String? id,
    int? accountId,
    String? name,
    int? age,
    String? avatar,
    int? points,
    int? streak,
    int? longestStreak,
    DateTime? lastStudyDate,
    List<String>? studyDates,
    List<String>? unlockedBadges,
    List<String>? completedLevels,
    List<String>? wrongQuestions,
    String? lastCheckInDate,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      studyDates: studyDates ?? this.studyDates,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      completedLevels: completedLevels ?? this.completedLevels,
      wrongQuestions: wrongQuestions ?? this.wrongQuestions,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
    );
  }
}

class UserFeedback {
  final String id;
  final int accountId;
  final String userName;
  final String userEmail;
  final String content;
  final int rating;
  final DateTime createdAt;

  UserFeedback({
    required this.id,
    required this.accountId,
    required this.userName,
    required this.userEmail,
    required this.content,
    this.rating = 5,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'userName': userName,
      'userEmail': userEmail,
      'content': content,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserFeedback.fromMap(Map<String, dynamic> map) {
    return UserFeedback(
      id: map['id']?.toString() ?? '',
      accountId: map['accountId']?.toInt() ?? 0,
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      content: map['content'] ?? '',
      rating: map['rating']?.toInt() ?? 5,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserFeedback.fromJson(String source) => UserFeedback.fromMap(json.decode(source));
}
