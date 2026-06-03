# Test Check — Find and Run Affected Tests

Before modifying code, identify which existing tests cover the code you're about to change. After modifying code, run those tests and verify they still pass.

## Before changing code

1. Find test files related to the files you're modifying — check for co-located tests (`*.test.*`, `*.spec.*`), test directories (`__tests__/`, `tests/`), and imports that reference your target files
2. Run the affected tests and note their current state (passing, failing, skipped)
3. If no tests exist for the code you're changing, note this — it's not a blocker, but flag it in your status update

## After changing code

1. Run the same tests again
2. If any previously-passing test now fails, fix the regression before proceeding
3. If your change requires new test coverage (new public interface, new error path, new integration), write tests for those specific behaviors

Do not write tests for implementation details. Test observable behavior at module boundaries.

## Local Customizations

If `LOCAL.md` exists in this skill directory, load and follow it after these instructions. Local instructions override upstream where they conflict.
