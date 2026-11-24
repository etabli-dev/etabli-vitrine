// Copyright 2026 R. Heller
// SPDX-License-Identifier: AGPL-3.0-only

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';

/// Why an import, download or staging step was refused; the UI shows a localized message for each.
enum ImportErrorKind {
  sizeLimit,
  notZip,
  notShinyApp,
  sourcesLimit,
  noAppR,
  urlScheme,
  httpStatus,
  archiveUnsafe,
  archiveLinks,
  archiveEmpty,
  runtimeIncomplete,
}

/// A refused import (still a [FormatException], so callers and tests keep working).
class ImportException extends FormatException {
  const ImportException(this.kind, super.message, [this.detail = '']);
  final ImportErrorKind kind;

  /// A value for the message, e.g. the HTTP status.
  final String detail;
}

/// A localized message for [error]; unknown errors keep their own text.
String describeImportError(Object error, AppLocalizations l) {
  if (error is ImportException) {
    return switch (error.kind) {
      ImportErrorKind.sizeLimit => l.errorSizeLimit,
      ImportErrorKind.notZip => l.errorNotZip,
      ImportErrorKind.notShinyApp => l.errorNotShinyApp,
      ImportErrorKind.sourcesLimit => l.errorSourcesLimit,
      ImportErrorKind.noAppR => l.errorNoAppR,
      ImportErrorKind.urlScheme => l.errorUrlScheme,
      ImportErrorKind.httpStatus => l.errorHttpStatus(error.detail),
      ImportErrorKind.archiveUnsafe => l.errorArchiveUnsafe,
      ImportErrorKind.archiveLinks => l.errorArchiveLinks,
      ImportErrorKind.archiveEmpty => l.errorArchiveEmpty,
      ImportErrorKind.runtimeIncomplete => l.errorRuntimeIncomplete,
    };
  }
  if (error is TimeoutException) return l.errorTimeout;
  if (error is SocketException || error is http.ClientException) {
    return l.errorNetwork;
  }
  if (error is FormatException) return error.message;
  return '$error';
}
