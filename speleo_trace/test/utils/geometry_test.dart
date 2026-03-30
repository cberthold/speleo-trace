import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:speleo_trace/utils/geometry.dart';

void main() {
  group('Geometry Utils', () {
    group('given_normalizeHeading0360', () {
      test('when_heading_is_370_then_should_return_10', () {
        // Arrange
        const double input = 370.0;

        // Act
        final result = normalizeHeading0360(input);

        // Assert
        expect(result, 10.0);
      });

      test('when_heading_is_negative_10_then_should_return_350', () {
        // Arrange
        const double input = -10.0;

        // Act
        final result = normalizeHeading0360(input);

        // Assert
        expect(result, 350.0);
      });

      test('when_heading_is_359_95_then_should_return_0', () {
        // Arrange
        const double input = 359.95;

        // Act
        final result = normalizeHeading0360(input);

        // Assert
        expect(result, 0.0);
      });
    });

    group('given_distanceMeters', () {
      test('when_calculating_distance_between_two_points_then_should_return_correct_distance', () {
        // Arrange
        final a = LatLng(0, 0);
        final b = LatLng(0, 1);

        // Act
        final result = distanceMeters(a, b);

        // Assert
        expect(result, closeTo(111319.5, 1)); // Approximate distance in meters
      });
    });

    group('given_bearingDegrees', () {
      test('when_calculating_bearing_from_north_to_east_then_should_return_90', () {
        // Arrange
        final from = LatLng(0, 0);
        final to = LatLng(0, 1);

        // Act
        final result = bearingDegrees(from, to);

        // Assert
        expect(result, closeTo(90, 0.1));
      });
    });

    group('given_intersectBearings', () {
      test('when_two_perpendicular_bearings_then_should_return_intersection', () {
        // Arrange
        final p1 = LatLng(0, 0);
        final p2 = LatLng(0, 1);
        const heading1 = 0.0; // North
        const heading2 = 90.0; // East

        // Act
        final result = intersectBearings(p1, heading1, p2, heading2);

        // Assert
        expect(result, isNotNull);
        expect(result!.latitude, closeTo(0, 0.001));
        expect(result.longitude, closeTo(0, 0.001));
      });

      test('when_parallel_bearings_then_should_return_null', () {
        // Arrange
        final p1 = LatLng(0, 0);
        final p2 = LatLng(0, 1);
        const heading1 = 0.0; // North
        const heading2 = 0.0; // North

        // Act
        final result = intersectBearings(p1, heading1, p2, heading2);

        // Assert
        expect(result, isNull);
      });
    });

    group('given_pairwiseIntersections', () {
      test('when_no_paths_then_should_return_empty_list', () {
        // Arrange
        const paths = <({LatLng point, double headingDeg})>[];

        // Act
        final result = pairwiseIntersections(paths);

        // Assert
        expect(result, isEmpty);
      });

      test('when_one_path_then_should_return_empty_list', () {
        // Arrange
        final paths = [
          (point: LatLng(0, 0), headingDeg: 0.0),
        ];

        // Act
        final result = pairwiseIntersections(paths);

        // Assert
        expect(result, isEmpty);
      });

      test('when_two_perpendicular_paths_then_should_return_one_intersection', () {
        // Arrange
        final paths = [
          (point: LatLng(0, 0), headingDeg: 0.0), // North
          (point: LatLng(0, 1), headingDeg: 90.0), // East
        ];

        // Act
        final result = pairwiseIntersections(paths);

        // Assert
        expect(result.length, 1);
        expect(result.first.latitude, closeTo(0, 0.001));
        expect(result.first.longitude, closeTo(0, 0.001));
      });
    });

    group('given_pointAhead', () {
      test('when_moving_north_then_should_return_correct_point', () {
        // Arrange
        final start = LatLng(0, 0);
        const heading = 0.0; // North
        const distance = 1000.0; // 1 km

        // Act
        final result = pointAhead(start, heading, distance);

        // Assert
        expect(result.latitude, closeTo(0.009, 0.001)); // Approximate
        expect(result.longitude, closeTo(0, 0.001));
      });
    });

    group('given_centroidLatLng', () {
      test('when_single_point_then_should_return_same_point', () {
        // Arrange
        final points = [LatLng(0, 0)];

        // Act
        final result = centroidLatLng(points);

        // Assert
        expect(result.latitude, 0);
        expect(result.longitude, 0);
      });

      test('when_multiple_points_then_should_return_centroid', () {
        // Arrange
        final points = [
          LatLng(0, 0),
          LatLng(0, 2),
          LatLng(2, 0),
          LatLng(2, 2),
        ];

        // Act
        final result = centroidLatLng(points);

        // Assert
        expect(result.latitude, closeTo(1, 0.001));
        expect(result.longitude, closeTo(1, 0.001));
      });
    });
  });
}