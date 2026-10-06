/// Shared contract tests for komovia_core's [Game] interface.
///
/// Each game package (komovia_shogi, komovia_go, ...) imports this from its
/// own `test/` directory and calls `runGameContractTests` against its
/// implementation, so a new game is only "done" once it passes the same
/// suite every other game does.
library;

export 'src/testkit/contract_tests.dart';
