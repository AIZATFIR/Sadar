const test = require('node:test');
const assert = require('node:assert/strict');
const {
  applyFocusClockResult,
  parseFocusClockResult,
} = require('../focus_clock_web_callback.js');

const startedAt = new Date(2026, 10, 12, 9, 0).getTime();
const endedAt = startedAt + 25 * 60 * 1000;

function callbackSearch(overrides = {}) {
  const params = new URLSearchParams({
    fc_version: '1',
    fc_session: 'session-1',
    fc_habit: 'habit-8',
    fc_started: String(startedAt),
    fc_ended: String(endedAt),
    fc_duration: '25',
    fc_status: 'completed',
    ...overrides,
  });
  return `?${params}`;
}

function makeState() {
  return {
    habits: [{
      id: 'habit-8',
      sessionsLast30Days: 3,
      accumulatedDays: 2,
    }],
    logs: {},
    saves: 0,
    saveStorage() { this.saves += 1; },
  };
}

test('applies a completed web session to its Sadar habit once', () => {
  const state = makeState();
  const result = parseFocusClockResult(callbackSearch(), state.habits);

  assert.ok(result);
  assert.equal(
    applyFocusClockResult(state, result, '2026-11-12'),
    'applied',
  );
  assert.equal(
    applyFocusClockResult(state, result, '2026-11-12'),
    'duplicate',
  );
  const secondSession = {
    ...result,
    sessionId: 'session-2',
    durationMinutes: 10,
  };
  assert.equal(
    applyFocusClockResult(state, secondSession, '2026-11-12'),
    'applied',
  );

  const log = state.logs['2026-11-12_habit-8'];
  assert.equal(log.status, 'done');
  assert.equal(log.actualDurationMinutes, 35);
  assert.equal(log.source, 'focus_clock');
  assert.deepEqual(log.focusClockSessionIds, ['session-1', 'session-2']);
  assert.equal(state.habits[0].sessionsLast30Days, 4);
  assert.equal(state.habits[0].accumulatedDays, 3);
  assert.equal(state.saves, 2);
});

test('ignores cancelled sessions and malformed callbacks', () => {
  const state = makeState();
  const cancelled = parseFocusClockResult(
    callbackSearch({ fc_status: 'cancelled' }),
    state.habits,
  );

  assert.equal(applyFocusClockResult(state, cancelled, '2026-11-12'), 'ignored');
  assert.equal(
    parseFocusClockResult(callbackSearch({ fc_ended: String(startedAt - 1) }), state.habits),
    null,
  );
  assert.deepEqual(state.logs, {});
  assert.equal(state.saves, 0);
});

test('rejects a return for a habit removed before the callback arrives', () => {
  const state = makeState();
  const result = parseFocusClockResult(callbackSearch(), []);

  assert.equal(result, null);
  assert.equal(applyFocusClockResult(state, result, '2026-11-12'), 'ignored');
  assert.deepEqual(state.logs, {});
  assert.equal(state.saves, 0);
});
