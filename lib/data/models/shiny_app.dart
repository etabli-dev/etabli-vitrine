import 'resolution_status.dart';
import 'source_type.dart';

/// Domain entity for a display-case entry. Decoupled from the drift row so the
/// UI works with typed enums rather than raw integer indices.
class ShinyApp {
  const ShinyApp({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.resolutionState,
    required this.importedAt,
    this.resolutionDetail,
    this.stagedPath,
    this.sourceUri,
    this.lastRunAt,
  });

  final String id;
  final String name;
  final SourceType sourceType;
  final ResolutionState resolutionState;
  final String? resolutionDetail;
  final String? stagedPath;
  final String? sourceUri;
  final DateTime importedAt;
  final DateTime? lastRunAt;
}
