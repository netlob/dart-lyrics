import 'package:http/http.dart' as http;

class Lyrics {
  final String _url =
      "https://www.google.com/search?client=safari&rls=en&ie=UTF-8&oe=UTF-8&q=";

  // DELIMITERS

  // Lyrics Delimiter
  String _delimiter1 =
      '</div></div></div></div><div class="hwc"><div class="BNeawe tAd8D AP7Wnd"><div><div class="BNeawe tAd8D AP7Wnd">';
  String _delimiter2 =
      '</div></div></div></div></div><div><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

  // Source Delimiter
  String _srcDelimiter1 =
      '<span class="BNeawe"><a href="https://www.musixmatch.com/"><span class="uEec3 AP7Wnd">';
  String _srcDelimiter2 =
      '</span></a></span></div></span><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

  // Songwriters Delimiter
  String _songwriterDelimiter1 =
      '</span></a></span></div></span><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

  String _songwriterDelimiter2 =
      '</div></span></div></div></div><hr></div><div class="duf-h"><div class="fLtXsc iIWm4b" aria-expanded="false" id="tsuid_1" style="text-align:center" role="button" tabindex="0"><div class="Lym8W"><div class="AeQQub hwc"></div><div class="YCU7eb hwc"></div>';

  Lyrics(
      {delimiter1,
      delimiter2,
      srcDelimiter1,
      srcDelimiter2,
      songwriterDelimiter1,
      songwriterDelimiter2}) {
    this.setDelimiters(
      delimiter1: delimiter1,
      delimiter2: delimiter2,
      srcDelimiter1: srcDelimiter1,
      srcDelimiter2: srcDelimiter2,
    );
  }

  void setDelimiters({
    String? delimiter1,
    String? delimiter2,
    String? srcDelimiter1,
    String? srcDelimiter2,
    String? songwriterDelimiter1,
    String? songwriterDelimiter2,
  }) {
    _delimiter1 = delimiter1 ?? _delimiter1;
    _delimiter2 = delimiter2 ?? _delimiter2;
    _srcDelimiter1 = srcDelimiter1 ?? _srcDelimiter1;
    _srcDelimiter2 = srcDelimiter2 ?? _srcDelimiter2;
    _songwriterDelimiter1 = songwriterDelimiter1 ?? _songwriterDelimiter1;
    _songwriterDelimiter2 = songwriterDelimiter2 ?? _songwriterDelimiter2;
  }

  Future<String> getLyrics({String? track, String? artist}) async {
    if (track == null || artist == null)
      throw Exception("track and artist must not be null");

    String lyrics;

    // try multiple queries
    try {
      lyrics = (await http.get(
              Uri.parse(Uri.encodeFull('${_url}$track by $artist lyrics'))))
          .body;
      //print(lyrics);
      lyrics = lyrics.split(_delimiter1).last;

      lyrics = lyrics.split(_delimiter2).first;
      if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
    } catch (_) {
      try {
        lyrics = (await http.get(Uri.parse(
                Uri.encodeFull('${_url}$track by $artist song lyrics'))))
            .body;
        lyrics = lyrics.split(_delimiter1).last;
        lyrics = lyrics.split(_delimiter2).first;
        if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
      } catch (_) {
        try {
          lyrics = (await http.get(Uri.parse(Uri.encodeFull(
                  '${_url}${track.split("-").first} by $artist lyrics'))))
              .body;
          lyrics = lyrics.split(_delimiter1).last;
          lyrics = lyrics.split(_delimiter2).first;
          if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
        } catch (_) {
          // give up
          throw Exception("no lyrics found");
        }
      }
    }

    final List<String> split = lyrics.split('\n');
    String result = '';
    for (var i = 0; i < split.length; i++) {
      result = '${result}${split[i]}\n';
    }
    return result.trim();
  }

  Future<String> getSource({String? track, String? artist}) async {
    if (track == null || artist == null)
      throw Exception("track and artist must not be null");

    String source;

    try {
      source = (await http.get(
              Uri.parse(Uri.encodeFull('${_url}$track by $artist lyrics'))))
          .body;

      source = source.split(_srcDelimiter1).last.toString();
      source = source.split(_srcDelimiter2).first.toString();

      if (source.indexOf('<meta charset="UTF-8">') > -1) throw Error();
    } catch (e) {
      throw Exception("no source found");
    }
    return source.trim();
  }

  Future<String> getSongwriters({String? track, String? artist}) async {
    if (track == null || artist == null)
      throw Exception("track and artist must not be null");

    String songwriters;

    try {
      songwriters = (await http.get(
              Uri.parse(Uri.encodeFull('${_url}$track by $artist lyrics'))))
          .body;

      songwriters = songwriters.split(_songwriterDelimiter1).last;
      songwriters = songwriters.split(_songwriterDelimiter2).first;

      if (songwriters.indexOf('<meta charset="UTF-8">') > -1) throw Error();
    } catch (e) {
      throw Exception("no songwriters found");
    }

    final List<String> split = songwriters.split('\n');
    String result = '';
    for (var i = 0; i < split.length; i++) {
      result = '${result}${split[i]}\n';
    }
    return result.substring(14);
  }
}
