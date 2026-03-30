import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:speleo_trace/src/models/intersection_compass_strategy.dart';

void main() {
  group('IntersectionCompassStrategy', () {
    group('given_FirstIntersectionStrategy', () {
      test('when_resolving_intersections_then_should_return_first', () {
        // Arrange
        final strategy = FirstIntersectionStrategy();
        final intersections = [
          LatLng(0, 0),
          LatLng(1, 1),
          LatLng(2, 2),
        ];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result, LatLng(0, 0));
      });

      test('when_no_intersections_then_should_return_null', () {
        // Arrange
        final strategy = FirstIntersectionStrategy();
        const intersections = <LatLng>[];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result, isNull);
      });
    });

    group('given_LastIntersectionStrategy', () {
      test('when_resolving_intersections_then_should_return_last', () {
        // Arrange
        final strategy = LastIntersectionStrategy();
        final intersections = [
          LatLng(0, 0),
          LatLng(1, 1),
          LatLng(2, 2),
        ];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result, LatLng(2, 2));
      });
    });

    group('given_AverageIntersectionStrategy', () {
      test('when_resolving_intersections_then_should_return_centroid', () {
        // Arrange
        final strategy = AverageIntersectionStrategy();
        final intersections = [
          LatLng(0, 0),
          LatLng(0, 2),
          LatLng(2, 0),
          LatLng(2, 2),
        ];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result!.latitude, closeTo(1, 0.001));
        expect(result.longitude, closeTo(1, 0.001));
      });
    });

    group('given_IndexedIntersectionStrategy', () {
      test('when_index_is_valid_then_should_return_correct_intersection', () {
        // Arrange
        final strategy = IndexedIntersectionStrategy(1);
        final intersections = [
          LatLng(0, 0),
          LatLng(1, 1),
          LatLng(2, 2),
        ];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result, LatLng(1, 1));
      });

      test('when_index_is_out_of_bounds_then_should_return_null', () {
        // Arrange
        final strategy = IndexedIntersectionStrategy(5);
        final intersections = [
          LatLng(0, 0),
          LatLng(1, 1),
        ];

        // Act
        final result = strategy.resolve(intersections);

        // Assert
        expect(result, isNull);
      });
    });

    group('given_equality', () {
      test('when_same_strategies_then_should_be_equal', () {
        // Arrange
        final s1 = FirstIntersectionStrategy();
        final s2 = FirstIntersectionStrategy();

        // Act & Assert
        expect(s1 == s2, true);
        expect(s1.hashCode == s2.hashCode, true);
      });

      test('when_different_strategies_then_should_not_be_equal', () {
        // Arrange
        final s1 = FirstIntersectionStrategy();
        final s2 = LastIntersectionStrategy();

        // Act & Assert
        expect(s1 == s2, false);
      });

      test('when_indexed_strategies_with_same_index_then_should_be_equal', () {
        // Arrange
        final s1 = IndexedIntersectionStrategy(1);
        final s2 = IndexedIntersectionStrategy(1);

        // Act & Assert
        expect(s1 == s2, true);
        expect(s1.hashCode == s2.hashCode, true);
      });

      test('when_indexed_strategies_with_different_index_then_should_not_be_equal', () {
        // Arrange
        final s1 = IndexedIntersectionStrategy(1);
        final s2 = IndexedIntersectionStrategy(2);

        // Act & Assert
        expect(s1 == s2, false);
      });
    });
  });
}