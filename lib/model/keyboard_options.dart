import 'types.dart';

const List<String> romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];

final List<ChordType> triadTypes = [
  ChordType(label: 'M', alt: 'M', value: ''), 
  ChordType(label: 'm', alt: 'm', value: ''), 
  ChordType(label: '°', alt: '°', value: '°'), 
  ChordType(label: '+', alt: '+', value: '+'), 
  ChordType(label: 'sus4', alt: 'sus4', value: 'sus4'), 
  ChordType(label: 'sus2', alt: 'sus2', value: 'sus2'), 
  ChordType(label: '5', alt: '5', value: '5'), 
  ChordType(label: 'no5', alt: 'no5', value: 'no5'),
];

final ExtendedChordTypes seventhTypes = {
    // Triads
  'M': [
    ChordType(label: 'M7', alt: 'M7', value: 'M7'),
    ChordType(label: '7', alt: '7', value: '7'),
    ChordType(label: '6', alt: '6', value: '6'),
  ],
  'm': [
    ChordType(label: '7', alt: 'm7', value: '7'),
    ChordType(label: 'M7', alt: 'mM7', value: 'mM7'),
    ChordType(label: '6', alt: 'm6', value: '6'),
  ],
  '°': [
    ChordType(label: '7♭5', alt: '7♭5', value: 'ø7'),
    ChordType(label: 'dim7', alt: 'dim7', value: '°7'),
  ],
  '+': [
    ChordType(label: '7♯5', alt: '7♯5', value: '7♯5'),
    ChordType(label: 'M7♯5', alt: 'M7♯5', value: 'M7♯5'),
  ],
  'sus4': [
    ChordType(label: '7', alt: '7sus4', value: '7sus4'),
  ],
  'sus2': [
    ChordType(label: '7', alt: '7sus2', value: '7sus2'),
  ],
};

final ExtendedChordTypes ninthTypes = {
  // Triads
  'M': [ChordType(label: 'add9', alt: 'add9', value: '(add9)')],
  'm': [ChordType(label: 'add9', alt: 'add9', value: '(add9)')],
  '°': [ChordType(label: 'add9', alt: 'add9', value: '°(add9)')],
  '+': [ChordType(label: 'add9', alt: 'add9', value: '+(add9)')],
  'sus4': [ChordType(label: 'add9', alt: 'add9', value: 'sus4(add9)')],
  '5': [ChordType(label: 'add9', alt: 'add9', value: '5(add9)')],

  // Sevenths
  'M7': [ChordType(label: '9', alt: 'M9', value: 'M9'), ChordType(label: '♭9', alt: 'M7♭9', value: 'M7♭9'), ChordType(label: '♯9', alt: 'M7♯9', value: 'M7♯9')],
  '7': [ChordType(label: '9', alt: '9', value: '9'), ChordType(label: '♭9', alt: '7♭9', value: '7♭9'), ChordType(label: '♯9', alt: '7♯9', value: '7♯9')],
  'm7': [ChordType(label: '9', alt: 'm9', value: '9'), ChordType(label: '♭9', alt: 'm7♭9', value: '7♭9')],
  'mM7': [ChordType(label: '9', alt: 'mM9', value: 'mM9'), ChordType(label: '♭9', alt: 'mM7♭9', value: 'mM7♭9')],
  '6': [ChordType(label: '9', alt: '6/9', value: '6/9'), ChordType(label: '♭9', alt: '6/♭9', value: '6/♭9'), ChordType(label: '♯9', alt: '6/♯9', value: '6/♯9')],
  'm6': [ChordType(label: '9', alt: 'm6/9', value: '6/9'), ChordType(label: '♭9', alt: 'm6/♭9', value: '6/♭9')],
  '7♭5': [ChordType(label: '9', alt: '9♭5', value: '9♭5'), ChordType(label: '♭9', alt: '7♭5♭9', value: '7♭5♭9')],
  'dim7': [ChordType(label: '9', alt: '°9♭5', value: '°9♭5'), ChordType(label: '♭9', alt: '°7♭5♭9', value: '°7♭5♭9')],
  '7♯5': [ChordType(label: '9', alt: '9♯5', value: '9♯5'), ChordType(label: '♭9', alt: '7♯5♭9', value: '7♯5♭9'), ChordType(label: '♯9', alt: '7♯5♯9', value: '7♯5♯9')],
  'M7♯5': [ChordType(label: '9', alt: 'M9♯5', value: 'M9♯5'), ChordType(label: '♭9', alt: 'M7♯5♭9', value: 'M7♯5♭9'), ChordType(label: '♯9', alt: 'M7♯5♯9', value: 'M7♯5♯9')],
  '7sus4': [ChordType(label: '9', alt: '9sus4', value: '9sus4'), ChordType(label: '♭9', alt: '7♭9sus4', value: '7♭9sus4'), ChordType(label: '♯9', alt: '7♯9sus4', value: '7♯9sus4')],
  '7sus2': [ChordType(label: '♭9', alt: '7♭9sus2', value: '7♭9sus2'), ChordType(label: '♯9', alt: '7♯9sus2', value: '7♯9sus2')],
};

final ExtendedChordTypes eleventhTypes = {
  // Triads
  'M': [ChordType(label: 'add11', alt: 'add11', value: '(add11)')],
  'm': [ChordType(label: 'add11', alt: 'add11', value: '(add11)')],
  '°': [ChordType(label: 'add11', alt: 'add11', value: '°(add11)')],
  '+': [ChordType(label: 'add11', alt: 'add11', value: '+(add11)')],
  'sus2': [ChordType(label: 'add11', alt: 'add11', value: 'sus2(add11)')],
  '5': [ChordType(label: 'add11', alt: 'add11', value: '5(add11)')],

  // Sevenths
  // 'M7': [ChordType(label: '11', value: 'M11'), ChordType(label: '♭11', value: 'M♭11'), ChordType(label: '♯11', value: 'M♯11')],
  // '7': [ChordType(label: '11', value: '11'), ChordType(label: '♭11', value: '♭11'), ChordType(label: '♯11', value: '♯11')],
  // 'm7': [ChordType(label: '11', value: 'm11'), ChordType(label: '♭11', value: 'm♭11')],
  // 'mM7': [ChordType(label: '11', value: 'mM11'), ChordType(label: '♭11', value: 'mM♭11')],
  // '6': [ChordType(label: '11', value: '6/11'), ChordType(label: '♭11', value: '6/♭11'), ChordType(label: '♯11', value: '6/♯11')],
  // 'm6': [ChordType(label: '11', value: 'm6/11'), ChordType(label: '♭11', value: 'm6/♭11')],

  // Ninths
  'M9': [ChordType(label: '11', alt: 'M11', value: 'M11'), ChordType(label: '♯11', alt: 'M9♯11', value: 'M9♯11')],
  'M7♭9': [ChordType(label: '11', alt: 'M11♭9', value: 'M11♭9'), ChordType(label: '♯11', alt: 'M7♭9♯11', value: 'M7♭9♯11')],
  'M7♯9': [ChordType(label: '11', alt: 'M11♯9', value: 'M11♯9'), ChordType(label: '♯11', alt: 'M7♯9♯11', value: 'M7♯9♯11')],
  '9': [ChordType(label: '11', alt: '11', value: '11'), ChordType(label: '♯11', alt: '9♯11', value: '9♯11')],
  '7♭9': [ChordType(label: '11', alt: '11♭9', value: '11♭9'), ChordType(label: '♯11', alt: '7♭9♯11', value: '7♭9♯11')],
  '7♯9': [ChordType(label: '11', alt: '11♯9', value: '11♯9'), ChordType(label: '♯11', alt: '7♯9♯11', value: '7♯9♯11')],
  'm9': [ChordType(label: '11', alt: 'm11', value: '11'), ChordType(label: '♭11', alt: 'm9♭11', value: '9♭11'), ChordType(label: '♯11', alt: 'm9♯11', value: '9♯11')],
  'm7♭9': [ChordType(label: '11', alt: 'm11♭9', value: '11♭9'), ChordType(label: '♭11', alt: 'm7♭9♭11', value: '7♭9♭11'), ChordType(label: '♯11', alt: 'm7♭9♯11', value: '7♭9♯11')],
  'mM9': [ChordType(label: '11', alt: 'mM11', value: 'mM11'), ChordType(label: '♭11', alt: 'mM9♭11', value: 'mM9♭11'), ChordType(label: '♯11', alt: 'mM9♯11', value: 'mM9♯11')],
  'mM7♭9': [ChordType(label: '11', alt: 'mM11♭9', value: 'mM11♭9'), ChordType(label: '♭11', alt: 'mM7♭9♭11', value: 'mM7♭9♭11'), ChordType(label: '♯11', alt: 'mM7♭9♯11', value: 'mM7♭9♯11')],
  '6/9': [ChordType(label: '11', alt: '6/11', value: '6/11'), ChordType(label: '♯11', alt: '6/9♯11', value: '6/9♯11')],
  '6/♭9': [ChordType(label: '11', alt: '6/11♭9', value: '6/11♭9'), ChordType(label: '♯11', alt: '6/♭9♯11', value: '6/♭9♯11')],
  '6/♯9': [ChordType(label: '11', alt: '6/11♯9', value: '6/11♯9'), ChordType(label: '♯11', alt: '6/♯9♯11', value: '6/♯9♯11')],
  'm6/9': [ChordType(label: '11', alt: 'm6/11', value: '6/11'), ChordType(label: '♭11', alt: 'm6/9♭11', value: '6/9♭11'), ChordType(label: '♯11', alt: 'm6/9♯11', value: '6/9♯11')],
  'm6/♭9': [ChordType(label: '11', alt: 'm6/11♭9', value: '6/11♭9'), ChordType(label: '♭11', alt: 'm6/♭9♭11', value: '6/♭9♭11'), ChordType(label: '♯11', alt: 'm6/♭9♯11', value: '6/♭9♯11')],
  '9♭5': [ChordType(label: '11', alt: '11♭5', value: '11♭5'), ChordType(label: '♭11', alt: '9♭5♭11', value: '9♭5♭11')],
  '7♭5♭9': [ChordType(label: '11', alt: '11♭5♭9', value: '11♭5♭9'), ChordType(label: '♭11', alt: '7♭5♭9♭11', value: '7♭5♭9♭11')],
  '°9♭5': [ChordType(label: '11', alt: '°11♭5', value: '°11♭5'), ChordType(label: '♭11', alt: '°9♭5♭11', value: '°9♭5♭11')],
  '°7♭5♭9': [ChordType(label: '11', alt: '°11♭5♭9', value: '°11♭5♭9'), ChordType(label: '♭11', alt: '°7♭5♭9♭11', value: '°7♭5♭9♭11')],
  '9♯5': [ChordType(label: '11', alt: '11♯5', value: '11♯5'), ChordType(label: '♯11', alt: '9♯5♯11', value: '9♯5♯11')],
  '7♯5♭9': [ChordType(label: '11', alt: '11♯5♭9', value: '11♯5♭9'), ChordType(label: '♯11', alt: '7♯5♭9♯11', value: '7♯5♭9♯11')],
  '7♯5♯9': [ChordType(label: '11', alt: '11♯5♯9', value: '11♯5♯9'), ChordType(label: '♯11', alt: '7♯5♯9♯11', value: '7♯5♯9♯11')],
  'M9♯5': [ChordType(label: '11', alt: 'M11♯5', value: 'M11♯5'), ChordType(label: '♯11', alt: 'M9♯5♯11', value: 'M9♯5♯11')],
  'M7♯5♭9': [ChordType(label: '11', alt: 'M11♯5♭9', value: 'M11♯5♭9'), ChordType(label: '♯11', alt: 'M7♯5♭9♯11', value: 'M7♯5♭9♯11')],
  'M7♯5♯9': [ChordType(label: '11', alt: 'M11♯5♯9', value: 'M11♯5♯9'), ChordType(label: '♯11', alt: 'M7♯5♯9♯11', value: 'M7♯5♯9♯11')],
  '9sus4': [ChordType(label: '♭11', alt: '9♭11sus4', value: '9♭11sus4'), ChordType(label: '♯11', alt: '9♯11sus4', value: '9♯11sus4')],
  '7♭9sus4': [ChordType(label: '♭11', alt: '7♭9♭11sus4', value: '7♭9♭11sus4'), ChordType(label: '♯11', alt: '7♭9♯11sus4', value: '7♭9♯11sus4')],
  '7♯9sus4': [ChordType(label: '♭11', alt: '7♯9♭11sus4', value: '7♯9♭11sus4'), ChordType(label: '♯11', alt: '7♯9♯11sus4', value: '7♯9♯11sus4')],
  '7♭9sus2': [ChordType(label: '11', alt: '11♭9sus2', value: '11♭9sus2'), ChordType(label: '♭11', alt: '7♭9♭11sus2', value: '7♭9♭11sus2'), ChordType(label: '♯11', alt: '7♭9♯11sus2', value: '7♭9♯11sus2')],
  '7♯9sus2': [ChordType(label: '11', alt: '11♯9sus2', value: '11♯9sus2'), ChordType(label: '♭11', alt: '7♯9♭11sus2', value: '7♯9♭11sus2'), ChordType(label: '♯11', alt: '7♯9♯11sus2', value: '7♯9♯11sus2')],
};

final ExtendedChordTypes thirteenthTypes = {
  // Triads
  'M': [ChordType(label: 'add13', alt: 'add13', value: '(add13)')],
  'm': [ChordType(label: 'add13', alt: 'add13', value: '(add13)')],
  '°': [ChordType(label: 'add13', alt: 'add13', value: '°(add13)')],
  '+': [ChordType(label: 'add13', alt: 'add13', value: '+(add13)')],
  'sus2': [ChordType(label: 'add13', alt: 'add13', value: 'sus2(add13)')],
  '5': [ChordType(label: 'add13', alt: 'add13', value: '5(add13)')],

  // Sevenths
  // 'M7': [ChordType(label: '13', value: 'M13'), ChordType(label: '♭13', value: 'M♭13'), ChordType(label: '♯13', value: 'M♯13')],
  // '7': [ChordType(label: '13', value: '13'), ChordType(label: '♭13', value: '♭13'), ChordType(label: '♯13', value: '♯13')],
  // 'm7': [ChordType(label: '13', value: 'm13'), ChordType(label: '♭13', value: 'm♭13')],
  // 'mM7': [ChordType(label: '13', value: 'mM13'), ChordType(label: '♭13', value: 'mM♭13')],
  // '6': [ChordType(label: '13', value: '6/13'), ChordType(label: '♭13', value: '6/♭13'), ChordType(label: '♯13', value: '6/♯13')],
  // 'm6': [ChordType(label: '13', value: '6/13'), ChordType(label: '♭13', value: '6/♭13')],

  // Ninths
  // 'M9': [ChordType(label: '13', value: 'M13'), ChordType(label: '♯13', value: 'M♯13')],
  // 'M♭9': [ChordType(label: '13', value: 'M13♭9'), ChordType(label: '♯13', value: 'M♭9♯13')],
  // 'M♯9': [ChordType(label: '13', value: 'M13♯9'), ChordType(label: '♯13', value: 'M♯9♯13')],
  // '9': [ChordType(label: '13', value: '13'), ChordType(label: '♯13', value: '♯13')],
  // '♭9': [ChordType(label: '13', value: '13♭9'), ChordType(label: '♯13', value: '♭9♯13')],
  // '♯9': [ChordType(label: '13', value: '13♯9'), ChordType(label: '♯13', value: '♯9♯13')],

  // Elevenths
  'M11': [ChordType(label: '13', alt: 'M13', value: 'M13'), ChordType(label: '♭13', alt: 'M11♭13', value: 'M11♭13'), ChordType(label: '♯13', alt: 'M11♯13', value: 'M11♯13')],
  'M9♯11': [ChordType(label: '13', alt: 'M13♯11', value: 'M13♯11'), ChordType(label: '♭13', alt: 'M9♯11♭13', value: 'M9♯11♭13'), ChordType(label: '♯13', alt: 'M9♯11♯13', value: 'M9♯11♯13')],
  'M11♭9': [ChordType(label: '13', alt: 'M13♭9', value: 'M13♭9'), ChordType(label: '♭13', alt: 'M11♭9♭13', value: 'M11♭9♭13'),ChordType(label: '♯13', alt: 'M11♭9♯13', value: 'M11♭9♯13')],
  'M7♭9♯11': [ChordType(label: '13', alt: 'M13♭9♯11', value: 'M13♭9♯11'), ChordType(label: '♭13', alt: 'M7♭9♯11♭13', value: 'M7♭9♯11♭13'),ChordType(label: '♯13', alt: 'M7♭9♯11♯13', value: 'M7♭9♯11♯13')],
  'M11♯9': [ChordType(label: '13', alt: 'M13♯9', value: 'M13♯9'), ChordType(label: '♭13', alt: 'M11♯9♭13', value: 'M11♯9♭13'),ChordType(label: '♯13', alt: 'M11♯9♯13', value: 'M11♯9♯13')],
  'M7♯9♯11': [ChordType(label: '13', alt: 'M13♯9♯11', value: 'M13♯9♯11'), ChordType(label: '♭13', alt: 'M7♯9♯11♭13', value: 'M7♯9♯11♭13'),ChordType(label: '♯13', alt: 'M7♯9♯11♯13', value: 'M7♯9♯11♯13')],
  '11': [ChordType(label: '13', alt: '13', value: '13'), ChordType(label: '♭13', alt: '11♭13', value: '11♭13'), ChordType(label: '♯13', alt: '11♯13', value: '11♯13')],
  '9♯11': [ChordType(label: '13', alt: '13♯11', value: '13♯11'), ChordType(label: '♭13', alt: '9♯11♭13', value: '9♯11♭13'), ChordType(label: '♯13', alt: '9♯11♯13', value: '9♯11♯13')],
  '11♭9': [ChordType(label: '13', alt: '13♭9', value: '13♭9'), ChordType(label: '♭13', alt: '11♭9♭13', value: '11♭9♭13'), ChordType(label: '♯13', alt: '11♭9♯13', value: '11♭9♯13')],
  '7♭9♯11': [ChordType(label: '13', alt: '13♭9♯11', value: '13♭9♯11'), ChordType(label: '♭13', alt: '7♭9♯11♭13', value: '7♭9♯11♭13'), ChordType(label: '♯13', alt: '7♭9♯11♯13', value: '7♭9♯11♯13')],
  '11♯9': [ChordType(label: '13', alt: '13♯9', value: '13♯9'), ChordType(label: '♭13', alt: '11♯9♭13', value: '11♯9♭13'), ChordType(label: '♯13', alt: '11♯9♯13', value: '11♯9♯13')],
  '7♯9♯11': [ChordType(label: '13', alt: '13♯9♯11', value: '13♯9♯11'), ChordType(label: '♭13', alt: '7♯9♯11♭13', value: '7♯9♯11♭13'), ChordType(label: '♯13', alt: '7♯9♯11♯13', value: '7♯9♯11♯13')],
  'm11': [ChordType(label: '13', alt: 'm13', value: '13'), ChordType(label: '♭13', alt: 'm11♭13', value: '11♭13')],
  'm9♭11': [ChordType(label: '13', alt: 'm13♭11', value: '13♭11'), ChordType(label: '♭13', alt: 'm9♭11♭13', value: '9♭11♭13')],
  'm9♯11': [ChordType(label: '13', alt: 'm13♯11', value: '13♯11'), ChordType(label: '♭13', alt: 'm9♯11♭13', value: '9♯11♭13')],
  'm11♭9': [ChordType(label: '13', alt: 'm13♭9', value: '13♭9'), ChordType(label: '♭13', alt: 'm11♭9♭13', value: '11♭9♭13')],
  'm7♭9♭11': [ChordType(label: '13', alt: 'm13♭9♭11', value: '13♭9♭11'), ChordType(label: '♭13', alt: 'm7♭9♭11♭13', value: '7♭9♭11♭13')],
  'm7♭9♯11': [ChordType(label: '13', alt: 'm13♭9♯11', value: '13♭9♯11'), ChordType(label: '♭13', alt: 'm7♭9♯11♭13', value: '7♭9♯11♭13')],
  'mM11': [ChordType(label: '13', alt: 'mM13', value: 'mM13'), ChordType(label: '♭13', alt: 'mM11♭13', value: 'mM11♭13'), ChordType(label: '♯13', alt: 'mM11♯13', value: 'mM11♯13')],
  'mM9♭11': [ChordType(label: '13', alt: 'mM13♭11', value: 'mM13♭11'), ChordType(label: '♭13', alt: 'mM9♭11♭13', value: 'mM9♭11♭13'), ChordType(label: '♯13', alt: 'mM9♭11♯13', value: 'mM9♭11♯13')],
  'mM9♯11': [ChordType(label: '13', alt: 'mM13♯11', value: 'mM13♯11'), ChordType(label: '♭13', alt: 'mM9♯11♭13', value: 'mM9♯11♭13'), ChordType(label: '♯13', alt: 'mM9♯11♯13', value: 'mM9♯11♯13')],
  'mM11♭9': [ChordType(label: '13', alt: 'mM13♭9', value: 'mM13♭9'), ChordType(label: '♭13', alt: 'mM11♭9♭13', value: 'mM11♭9♭13'), ChordType(label: '♯13', alt: 'mM11♭9♯13', value: 'mM11♭9♯13')],
  'mM7♭9♭11': [ChordType(label: '13', alt: 'mM13♭9♭11', value: 'mM13♭9♭11'), ChordType(label: '♭13', alt: 'mM7♭9♭11♭13', value: 'mM7♭9♭11♭13'), ChordType(label: '♯13', alt: 'mM7♭9♭11♯13', value: 'mM7♭9♭11♯13')],
  'mM7♭9♯11': [ChordType(label: '13', alt: 'mM13♭9♯11', value: 'mM13♭9♯11'), ChordType(label: '♭13', alt: 'mM♭9♯11♭13', value: 'mM♭9♯11♭13'), ChordType(label: '♯13', alt: 'mM♭9♯11♯13', value: 'mM♭9♯11♯13')],
  '6/11': [ChordType(label: '♭13', alt: '6/11♭13', value: '6/11♭13'), ChordType(label: '♯13', alt: '6/11♯13', value: '6/11♯13')],
  '6/9♯11': [ChordType(label: '♭13', alt: '6/9♯11♭13', value: '6/9♯11♭13'), ChordType(label: '♯13', alt: '6/9♯11♯13', value: '6/9♯11♯13')],
  '6/11♭9': [ChordType(label: '♭13', alt: '6/11♭9♭13', value: '6/11♭9♭13'), ChordType(label: '♯13', alt: '6/11♭9♯13', value: '6/11♭9♯13')],
  '6/♭9♯11': [ChordType(label: '♭13', alt: '6/♭9♯11♭13', value: '6/♭9♯11♭13'), ChordType(label: '♯13', alt: '6/♭9♯11♯13', value: '6/♭9♯11♯13')],
  '6/11♯9': [ChordType(label: '♭13', alt: '6/11♯9♭13', value: '6/11♯9♭13'), ChordType(label: '♯13', alt: '6/11♯9♯13', value: '6/11♯9♯13')],
  '6/♯9♯11': [ChordType(label: '♭13', alt: '6/♯9♯11♭13', value: '6/♯9♯11♭13'), ChordType(label: '♯13', alt: '6/♯9♯11♯13', value: '6/♯9♯11♯13')],
  'm6/11': [ChordType(label: '♭13', alt: 'm6/11♭13', value: '6/11♭13'), ChordType(label: '♯13', alt: 'm6/11♯13', value: '6/11♯13')],
  'm6/9♭11': [ChordType(label: '♭13', alt: 'm6/9♭11♭13', value: '6/9♭11♭13'), ChordType(label: '♯13', alt: 'm6/9♭11♯13', value: '6/9♭11♯13')],
  'm6/9♯11': [ChordType(label: '♭13', alt: 'm6/9♯11♭13', value: '6/9♯11♭13'), ChordType(label: '♯13', alt: 'm6/9♯11♯13', value: '6/9♯11♯13')],
  'm6/11♭9': [ChordType(label: '♭13', alt: 'm6/11♭9♭13', value: '6/11♭9♭13'), ChordType(label: '♯13', alt: 'm6/11♭9♯13', value: '6/11♭9♯13')],
  'm6/♭9♭11': [ChordType(label: '♭13', alt: 'm6/♭9♭11♭13', value: '6/♭9♭11♭13'), ChordType(label: '♯13', alt: 'm6/♭9♭11♯13', value: '6/♭9♭11♯13')],
  'm6/♭9♯11': [ChordType(label: '♭13', alt: 'm6/♭9♯11♭13', value: '6/♭9♯11♭13'), ChordType(label: '♯13', alt: 'm6/♭9♯11♯13', value: '6/♭9♯11♯13')],
  '11♭5': [ChordType(label: '♭13', alt: '11♭5♭13', value: '11♭5♭13'), ChordType(label: '♯13', alt: '11♭5♯13', value: '11♭5♯13')],
  '9♭5♭11': [ChordType(label: '♭13', alt: '9♭5♭11♭13', value: '9♭5♭11♭13'), ChordType(label: '♯13', alt: '9♭5♭11♯13', value: '9♭5♭11♯13')],
  '11♭5♭9': [ChordType(label: '♭13', alt: '11♭5♭9♭13', value: '11♭5♭9♭13'), ChordType(label: '♯13', alt: '11♭5♭9♯13', value: '11♭5♭9♯13')],
  '7♭5♭9♭11': [ChordType(label: '♭13', alt: '7♭5♭9♭11♭13', value: '7♭5♭9♭11♭13'), ChordType(label: '♯13', alt: '7♭5♭9♭11♯13', value: '7♭5♭9♭11♯13')],
  '°11♭5': [ChordType(label: '♭13', alt: '°11♭5♭13', value: '°11♭5♭13'), ChordType(label: '♯13', alt: '°11♭5♯13', value: '°11♭5♯13')],
  '°9♭5♭11': [ChordType(label: '♭13', alt: '°9♭5♭11♭13', value: '°9♭5♭11♭13'), ChordType(label: '♯13', alt: '°9♭5♭11♯13', value: '°9♭5♭11♯13')],
  '°11♭5♭9': [ChordType(label: '♭13', alt: '°11♭5♭9♭13', value: '°11♭5♭9♭13'), ChordType(label: '♯13', alt: '°11♭5♭9♯13', value: '°11♭5♭9♯13')],
  '°7♭5♭9♭11': [ChordType(label: '♭13', alt: '°7♭5♭9♭11♭13', value: '°7♭5♭9♭11♭13'), ChordType(label: '♯13', alt: '°7♭5♭9♭11♯13', value: '°7♭5♭9♭11♯13')],
  '11♯5': [ChordType(label: '13', alt: '13♯5', value: '13♯5')],
  '9♯5♯11': [ChordType(label: '13', alt: '13♯5♯11', value: '13♯5♯11')],
  '11♯5♭9': [ChordType(label: '13', alt: '13♯5♭9', value: '13♯5♭9')],
  '7♯5♭9♯11': [ChordType(label: '13', alt: '13♯5♭9♯11', value: '13♯5♭9♯11')],
  '11♯5♯9': [ChordType(label: '13', alt: '13♯5♯9', value: '13♯5♯9')],
  '7♯5♯9♯11': [ChordType(label: '13', alt: '13♯5♯9♯11', value: '13♯5♯9♯11')],
  'M11♯5': [ChordType(label: '13', alt: 'M13♯5', value: 'M13♯5'), ChordType(label: '♯13', alt: 'M11♯5♯13', value: 'M11♯5♯13')],
  'M9♯5♯11': [ChordType(label: '13', alt: 'M13♯5♯11', value: 'M13♯5♯11'), ChordType(label: '♯13', alt: 'M♯13♯5♯11', value: 'M♯13♯5♯11')],
  'M11♯5♭9': [ChordType(label: '13', alt: 'M13♯5♭9', value: 'M13♯5♭9'), ChordType(label: '♯13', alt: 'M11♯5♭9♯13', value: 'M11♯5♭9♯13')],
  'M7♯5♭9♯11': [ChordType(label: '13', alt: 'M13♯5♭9♯11', value: 'M13♯5♭9♯11'), ChordType(label: '♯13', alt: 'M7♯5♭9♯11♯13', value: 'M7♯5♭9♯11♯13')],
  'M11♯5♯9': [ChordType(label: '13', alt: 'M13♯5♯9', value: 'M13♯5♯9'), ChordType(label: '♯13', alt: 'M11♯5♯9♯13', value: 'M11♯5♯9♯13')],
  'M7♯5♯9♯11': [ChordType(label: '13', alt: 'M13♯5♯9♯11', value: 'M13♯5♯9♯11'), ChordType(label: '♯13', alt: 'M7♯5♯9♯11♯13', value: 'M7♯5♯9♯11♯13')],
  '9♭11sus4': [ChordType(label: '13', alt: '13♭11sus4', value: '13♭11sus4'), ChordType(label: '♭13', alt: '9♭11♭13sus4', value: '9♭11♭13sus4')],
  '9♯11sus4': [ChordType(label: '13', alt: '13♯11sus4', value: '13♯11sus4'), ChordType(label: '♭13', alt: '9♯11♭13sus4', value: '9♯11♭13sus4')],
  '7♭9♭11sus4': [ChordType(label: '13', alt: '13♭9♭11sus4', value: '13♭9♭11sus4'), ChordType(label: '♭13', alt: '7♭9♭11♭13sus4', value: '7♭9♭11♭13sus4')],
  '7♭9♯11sus4': [ChordType(label: '13', alt: '13♭9♯11sus4', value: '13♭9♯11sus4'), ChordType(label: '♭13', alt: '7♭9♯11♭13sus4', value: '7♭9♯11♭13sus4')],
  '7♯9♭11sus4': [ChordType(label: '13', alt: '13♯9♭11sus4', value: '13♯9♭11sus4'), ChordType(label: '♭13', alt: '7♯9♭11♭13sus4', value: '7♯9♭11♭13sus4')],
  '7♯9♯11sus4': [ChordType(label: '13', alt: '13♯9♯11sus4', value: '13♯9♯11sus4'), ChordType(label: '♭13', alt: '7♯9♯11♭13sus4', value: '7♯9♯11♭13sus4')],
  '11♭9sus2': [ChordType(label: '13', alt: '13♭9sus2', value: '13♭9sus2'), ChordType(label: '♭13', alt: '11♭9♭13sus2', value: '11♭9♭13sus2')],
  '7♭9♭11sus2': [ChordType(label: '13', alt: '13♭9♭11sus2', value: '13♭9♭11sus2'), ChordType(label: '♭13', alt: '7♭9♭11♭13sus2', value: '7♭9♭11♭13sus2')],
  '7♭9♯11sus2': [ChordType(label: '13', alt: '13♭9♯11sus2', value: '13♭9♯11sus2'), ChordType(label: '♭13', alt: '7♭9♯11♭13sus2', value: '7♭9♯11♭13sus2')],
  '11♯9sus2': [ChordType(label: '13', alt: '13♯9sus2', value: '13♯9sus2'), ChordType(label: '♭13', alt: '11♯9♭13sus2', value: '11♯9♭13sus2')],
  '7♯9♭11sus2': [ChordType(label: '13', alt: '13♯9♭11sus2', value: '13♯9♭11sus2'), ChordType(label: '♭13', alt: '7♯9♭11♭13sus2', value: '7♯9♭11♭13sus2')],
  '7♯9♯11sus2': [ChordType(label: '13', alt: '13♯9♯11sus2', value: '13♯9♯11sus2'), ChordType(label: '♭13', alt: '7♯9♯11♭13sus2', value: '7♯9♯11♭13sus2')],
};

final inversionTypes = {
    // Triads
    '/2': ChordType(label: '/2', alt: '/2', value: '/2'),
    '/3': ChordType(label: '/3', alt: '/3', value: '/3'),
    '/4': ChordType(label: '/4', alt: '/4', value: '/4'),
    '/5': ChordType(label: '/5', alt: '/5', value: '/5'),

    // Sevenths
    '/7': ChordType(label: '/7', alt: '/7', value: '/7'),
    '/6': ChordType(label: '/6', alt: '/6', value: '/6'),

    // Ninths
    '/9': ChordType(label: '/9', alt: '/9', value: '/9'),

    // Elevenths
    '/11': ChordType(label: '/11', alt: '/11', value: '/11'),

    // Thirteenths
    '/13': ChordType(label: '/13', alt: '/13', value: '/13'),
};

const keyChangeTypes = {
  '–': [
    'K–m2',
    'K–M2',
    'K–m3',
    'K–M3',
    'K–P4',
    'K–TT',
    'K–P5',
    'K–m6',
    'K–M6',
    'K–m7',
    'K–M7',
  ],
  '+': [
    'K+m2',
    'K+M2',
    'K+m3',
    'K+M3',
    'K+P4',
    'K+TT',
    'K+P5',
    'K+m6',
    'K+M6',
    'K+m7',
    'K+M7',
  ],
};