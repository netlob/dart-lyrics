import 'package:http/http.dart' as http;

class Lyrics {
  final String _url =
      "https://www.google.com/search?client=safari&rls=en&ie=UTF-8&oe=UTF-8&q=";
  String _delimiter1 =
      '</div></div></div></div><div class="hwc"><div class="BNeawe tAd8D AP7Wnd"><div><div class="BNeawe tAd8D AP7Wnd">';
  String _delimiter2 =
      '</div></div></div></div></div><div><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

  Lyrics({delimiter1, delimiter2}) {
    this.setDelimiters(delimiter1: delimiter1, delimiter2: delimiter2);
  }

  void setDelimiters({String delimiter1, String delimiter2}) {
    _delimiter1 = delimiter1 ?? _delimiter1;
    _delimiter2 = delimiter2 ?? _delimiter2;
  }

  Future<String> getLyrics({String track, String artist}) async {
    if (track == null || artist == null)
      throw Exception("track and artist must not be null");

    String lyrics;

    // try multiple queries
    try {
      lyrics =
          (await http.get(Uri.encodeFull('${_url}$artist $track lyrics'))).body;
      lyrics = lyrics.split(_delimiter1).last;
      lyrics = lyrics.split(_delimiter2).first;
      if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
    } catch (_) {
      try {
        lyrics = (await http
                .get(Uri.encodeFull('${_url}$artist $track song lyrics')))
            .body;
        lyrics = lyrics.split(_delimiter1).last;
        lyrics = lyrics.split(_delimiter2).first;
        if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
      } catch (_) {
        try {
          lyrics =
              (await http.get(Uri.encodeFull('${_url}$track lyrics'))).body;
          lyrics = lyrics.split(_delimiter1).last;
          lyrics = lyrics.split(_delimiter2).first;
          if (lyrics.indexOf('<meta charset="UTF-8">') > -1) throw Error();
        } catch (_) {
          try {
            lyrics = (await http.get(Uri.encodeFull(
                    '${_url}${track.split("-").first} $artist lyrics')))
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
    }

    final List<String> split = lyrics.split('\n');
    String result = '';
    for (var i = 0; i < split.length; i++) {
      result = '${result}${split[i]}\n';
    }
    return result.trim();
  }
}
