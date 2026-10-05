import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mamacare/screens/facility/facility_locator_screen.dart';

void main() {
  test('buildOverpassUrl encodes the Overpass query for the target coordinates', () {
    final url = FacilityLocatorScreen.buildOverpassUrl(
      const LatLng(5.6037, -0.1870),
    );

    expect(url.origin, 'https://overpass-api.de');
    expect(url.path, '/api/interpreter');
    expect(url.queryParameters.containsKey('data'), isTrue);
    expect(url.queryParameters['data'], contains('around:5000'));
    expect(url.queryParameters['data'], contains('5.6037'));
    expect(url.queryParameters['data'], contains('-0.187'));
  });
}
