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
      tonic: json['tonic'],
      symbol: json['symbol'],
      mode: json['mode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tonic': tonic,
      'symbol': symbol,
      'mode': mode,
    };
  }
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
      sectionTitle: json['sectionTitle'],
      key: Key(
        tonic: json['key']['tonic'],
        symbol: json['key']['symbol'],
        mode: json['key']['mode'],
      ),
      chords: json['chords'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionTitle': sectionTitle,
      'key': key.toJson(),
      'chords': chords,
    };
  }
}

class Song {
  final String id;
  final String title;
  final String artist;
  final List<String> genres;
  final List<Section> sections;


  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genres,
    required this.sections,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      genres: List<String>.from(json['genres']),
      sections: (json['sections'] as List)
        .map((section) => Section.fromJson(section))
        .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genres': genres,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}