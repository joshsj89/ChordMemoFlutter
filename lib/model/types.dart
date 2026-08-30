class Key {
  final String tonic;
  final String symbol;
  final String mode;

  Key({
    required this.tonic,
    required this.symbol,
    required this.mode,
  });

  factory Key.fromJson(Map<String, dynamic> json) {
    return Key(
      tonic: (json['tonic'] as String?) ?? 'C',
      symbol: (json['symbol'] as String?) ?? '',
      mode: (json['mode'] as String?) ?? 'Major',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tonic': tonic,
      'symbol': symbol,
      'mode': mode,
    };
  }

  Key copyWith({
    String? tonic,
    String? symbol,
    String? mode,
  }) {
    return Key(
      tonic: tonic ?? this.tonic,
      symbol: symbol ?? this.symbol,
      mode: mode ?? this.mode,
    );
  }

  // for debugging: log(key.toString());
  // Returns the key in the format of 'C Major'
  @override
  String toString() {
    return '$tonic$symbol $mode';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Key) return false;

    return other.tonic == tonic &&
      other.symbol == symbol &&
      other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(tonic, symbol, mode);
}

class Section {
  final String sectionTitle;
  final Key key;
  final String chords;

  Section({
    required this.sectionTitle,
    required this.key,
    required this.chords,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionTitle: (json['sectionTitle'] as String?) ?? 'Whole',
      key: json['key'] is Map<String, dynamic>
          ? Key.fromJson(json['key'] as Map<String, dynamic>)
          : Key(tonic: 'C', symbol: '', mode: 'Major'),
      chords: (json['chords'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionTitle': sectionTitle,
      'key': key.toJson(),
      'chords': chords,
    };
  }

  Section copyWith({
    String? sectionTitle,
    Key? key,
    String? chords,
  }) {
    return Section(
      sectionTitle: sectionTitle ?? this.sectionTitle,
      key: key ?? this.key,
      chords: chords ?? this.chords,
    );
  }

  @override
  String toString() {
    return 'Section(sectionTitle: $sectionTitle, key: $key, chords: $chords)';
  }
}

class Song {
  final String id;
  final String title;
  final String artist;
  final List<String> genres;
  final List<Section> sections;

  // Optional metadata added after the original schema. These are nullable and
  // omitted from [toJson] when null, so songs exported by this version still
  // import cleanly into older builds (which ignore unknown fields) and songs
  // from older builds load here with these fields left null.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genres,
    required this.sections,
    this.createdAt,
    this.updatedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: (json['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: (json['title'] as String?) ?? '',
      artist: (json['artist'] as String?) ?? '',
      genres: json['genres'] is List
          ? List<String>.from(json['genres'] as List)
          : <String>[],
      sections: json['sections'] is List
          ? (json['sections'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Section.fromJson)
              .toList()
          : <Section>[],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genres': genres,
      'sections': sections.map((section) => section.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    List<String>? genres,
    List<Section>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genres: genres ?? this.genres,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, genres: $genres, sections: [${sections.map((s) => s.toString()).join(', ')}])';
  }
}

class ChordType {
  final String label;
  final String alt;
  final String value;

  ChordType({
    required this.label,
    required this.alt,
    required this.value,
  });
}

typedef ExtendedChordTypes = Map<String, List<ChordType>>;
