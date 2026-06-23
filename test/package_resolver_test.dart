import 'package:flutter_test/flutter_test.dart';
import 'package:vitrine/data/models/resolution_status.dart';
import 'package:vitrine/features/import/package_resolver.dart';

void main() {
  group('PackageResolver.scan', () {
    test('detects library/require and namespace calls', () {
      const src = '''
        library(shiny)
        require("ggplot2")
        dplyr::filter(x)
        requireNamespace('jsonlite')
      ''';
      final pkgs = PackageResolver.scan(src);
      expect(pkgs, containsAll(['shiny', 'ggplot2', 'dplyr', 'jsonlite']));
    });
  });

  group('PackageResolver.resolve', () {
    test('shiny-only app is ready (all bundled)', () {
      final r = PackageResolver.resolve('library(shiny)\nui <- fluidPage()');
      expect(r.state, ResolutionState.ready);
      expect(r.missing, isEmpty);
    });

    test('base packages do not count as missing', () {
      final r = PackageResolver.resolve('library(shiny); library(stats)');
      expect(r.state, ResolutionState.ready);
    });

    test('non-bundled package produces a warning', () {
      final r = PackageResolver.resolve('library(shiny)\nlibrary(ggplot2)');
      expect(r.state, ResolutionState.warnings);
      expect(r.missing, contains('ggplot2'));
      expect(r.detail, contains('ggplot2'));
    });

    test('shiny is always required even if not declared', () {
      final r = PackageResolver.resolve('ui <- fluidPage()');
      expect(r.required_, contains('shiny'));
    });
  });
}
