(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  if (root) root.SadarFocusClockCallback = api;
})(typeof globalThis === 'undefined' ? this : globalThis, function () {
  'use strict';

  function parseFocusClockResult(search, habits) {
    const params = new URLSearchParams(search);
    if (!params.has('fc_version')) return null;

    const sessionId = params.get('fc_session') || '';
    const habitId = params.get('fc_habit') || '';
    const startedAt = Number(params.get('fc_started'));
    const endedAt = Number(params.get('fc_ended'));
    const durationMinutes = Number(params.get('fc_duration'));
    const status = params.get('fc_status');
    const sessionIdIsValid = /^[A-Za-z0-9._:-]{1,128}$/.test(sessionId);

    if (
      params.get('fc_version') !== '1' ||
      !sessionIdIsValid ||
      !habitId ||
      !habits.some((habit) => habit.id === habitId) ||
      !Number.isSafeInteger(startedAt) ||
      !Number.isSafeInteger(endedAt) ||
      startedAt <= 0 ||
      endedAt < startedAt ||
      !Number.isInteger(durationMinutes) ||
      durationMinutes < 0 ||
      durationMinutes > 720 ||
      !['completed', 'cancelled', 'interrupted'].includes(status)
    ) {
      return null;
    }

    return { sessionId, habitId, startedAt, endedAt, durationMinutes, status };
  }

  function formatLocalDate(timestamp) {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  function applyFocusClockResult(state, result, today) {
    if (!result || result.status !== 'completed') return 'ignored';

    const habit = state.habits.find((item) => item.id === result.habitId);
    if (!habit) return 'missing_habit';

    const date = formatLocalDate(result.startedAt);
    const key = `${date}_${habit.id}`;
    const existing = state.logs[key] || { date, habitId: habit.id };
    const sessionIds = Array.isArray(existing.focusClockSessionIds)
      ? existing.focusClockSessionIds
      : [];
    if (sessionIds.includes(result.sessionId)) return 'duplicate';

    const wasDone = existing.status === 'done';
    const totalDuration = (Number(existing.actualDurationMinutes) || 0) + result.durationMinutes;
    state.logs[key] = {
      ...existing,
      date,
      habitId: habit.id,
      status: 'done',
      completedValueLabel: totalDuration === 0 ? '<1 min Fokus' : `${totalDuration} min Fokus`,
      actualDurationMinutes: totalDuration,
      source: 'focus_clock',
      focusClockSessionIds: [...sessionIds, result.sessionId],
      completedAt: result.endedAt,
    };

    if (date === today && !wasDone) {
      habit.sessionsLast30Days = (Number(habit.sessionsLast30Days) || 0) + 1;
      habit.accumulatedDays = (Number(habit.accumulatedDays) || 0) + 1;
    }

    state.saveStorage();
    return 'applied';
  }

  return { applyFocusClockResult, parseFocusClockResult };
});
