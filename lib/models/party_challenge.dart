import 'dart:math';
import 'package:flutter/foundation.dart';

/// Represents a fun handicap / challenge rule for a turn.
@immutable
class PartyChallenge {
  final String title;
  final String icon;
  final String description;

  const PartyChallenge({
    required this.title,
    required this.icon,
    required this.description,
  });

  /// All available party challenge handicaps
  static const List<PartyChallenge> allChallenges = [
    PartyChallenge(
      icon: '🤐',
      title: 'Sadece Yüz Mimikleri',
      description: 'Ellerini ve kollarını kullanma, sadece yüz mimikleri ve başınla anlat!',
    ),
    PartyChallenge(
      icon: '🪑',
      title: 'Oturarak Anlat',
      description: 'Olduğun yerden asla kalkmadan, koltuğa/sandalyeye oturarak anlat!',
    ),
    PartyChallenge(
      icon: '⏱️',
      title: 'İlk 10 Saniye Don!',
      description: 'Süre başladığında ilk 10 saniye heykel gibi hiç kımıldamadan bekle!',
    ),
    PartyChallenge(
      icon: '🦖',
      title: 'T-Rex Modu',
      description: 'Kollarını göğsüne yapıştırıp minik T-Rex kollarıyla anlat!',
    ),
    PartyChallenge(
      icon: '🕺',
      title: 'Dans Ederek Anlat',
      description: 'Anlatım boyunca sanki müzik çalıyormuş gibi dans etmeye devam et!',
    ),
    PartyChallenge(
      icon: '🦵',
      title: 'Tek Ayak Üstünde',
      description: 'Tüm anlatım boyunca tek ayak üstünde dengede durmaya çalış!',
    ),
    PartyChallenge(
      icon: '🎭',
      title: 'Ağır Çekim (Slow Motion)',
      description: 'Tüm hareketlerini sanki video yavaşlatılmış gibi ultra ağır çekimde yap!',
    ),
    PartyChallenge(
      icon: '🤖',
      title: 'Robot Modu',
      description: 'Sadece kesik kesik ve mekanik robotik hareketler sergile!',
    ),
    PartyChallenge(
      icon: '👀',
      title: 'Gözlerini Kırpmadan',
      description: 'Gözlerini hiç kırpmamaya çalışarak anlat!',
    ),
    PartyChallenge(
      icon: '🏃',
      title: 'Yerinde Koşarak',
      description: 'Anlatım boyunca olduğun yerde koşu temposunu hiç bozma!',
    ),
    PartyChallenge(
      icon: '🤫',
      title: 'Gözler Kapalı Başla',
      description: 'İlk 15 saniyeyi gözlerin tamamen kapalı şekilde anlat!',
    ),
    PartyChallenge(
      icon: '🧘',
      title: 'Yoga Pozunda Anlat',
      description: 'Bir yoga duruşuna geç ve o pozisyondan hiç çıkmadan hareket et!',
    ),
    PartyChallenge(
      icon: '🐧',
      title: 'Penguen Yürüyüşü',
      description: 'Kollarını vücuduna bitiştir ve minik adımlarla penguen gibi yürü!',
    ),
    PartyChallenge(
      icon: '💪',
      title: 'Sadece Tek El',
      description: 'Bir elini arkana bağla, yalnızca tek elini kullanarak anlat!',
    ),
    PartyChallenge(
      icon: '🧙‍♂️',
      title: 'Büyücü / Büyü Yaparak',
      description: 'Her hareketini sanki asa ile büyü yapıyormuş gibi dramatik yap!',
    ),
    PartyChallenge(
      icon: '👶',
      title: 'Bebek Gibi Emekle',
      description: 'Yerde emekleyerek veya çömelerek anlat!',
    ),
    PartyChallenge(
      icon: '⚡',
      title: 'Hızlı Çekim (2x Hız)',
      description: 'Tüm hareketlerini iki kat hızlı ve telaşlı yap!',
    ),
    PartyChallenge(
      icon: '🪞',
      title: 'Ayna Karşısında',
      description: 'Takımına arkasını dönüp duvara bakarak anlat!',
    ),
  ];

  /// Returns a random challenge from the catalog
  static PartyChallenge getRandom() {
    final random = Random();
    return allChallenges[random.nextInt(allChallenges.length)];
  }

  @override
  String toString() => '$icon $title: $description';
}
