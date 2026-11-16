const assert = require("node:assert/strict");
const {test} = require("node:test");
const timers = require("node:timers/promises");
const {describe_error, with_retry, get_json} = require("./request.js");

function http_error(status, message, headers = {}) {
  return Object.assign(new Error(message), {
    status,
    request: {url: "https://api.github.com/repos/NixOS/nixpkgs/commits/abc"},
    response: {headers},
  });
}

function capture_retries(t) {
  const delays = [];
  const warnings = [];
  t.mock.method(timers, "setTimeout", async (delay) => delays.push(delay));
  t.mock.method(console, "warn", (message) => warnings.push(message));
  return {delays, warnings};
}

test("transient failures retry with backoff and can recover", async (t) => {
  const {delays} = capture_retries(t);
  let attempts = 0;
  const result = await with_retry(async () => {
    if (++attempts < 3) throw http_error(503, "Service unavailable");
    return "recovered";
  });
  assert.equal(result, "recovered");
  assert.deepEqual(delays, [1000, 2000]);
});

test("repeated failures stop after three retries and preserve the error", async (t) => {
  const {delays} = capture_retries(t);
  const error = http_error(502, "Bad gateway");
  let attempts = 0;
  await assert.rejects(with_retry(async () => { attempts++; throw error; }),
    (actual) => actual === error);
  assert.equal(attempts, 4);
  assert.deepEqual(delays, [1000, 2000, 4000]);
});

test("authentication, permission, and not-found errors are not retried", async (t) => {
  const {delays} = capture_retries(t);
  for (const status of [401, 403, 404]) {
    const error = http_error(status, "Access denied");
    let attempts = 0;
    await assert.rejects(with_retry(async () => { attempts++; throw error; }),
      (actual) => actual === error);
    assert.equal(attempts, 1);
  }
  assert.deepEqual(delays, []);
});

test("rate limits respect Retry-After seconds, dates, and primary resets", async (t) => {
  const {delays} = capture_retries(t);
  const now = Date.parse("2026-11-16T14:00:00Z");
  t.mock.method(Date, "now", () => now);
  for (const [status, headers, expected] of [
    [403, {"retry-after": "5"}, 5000],
    [429, {"retry-after": "Mon, 16 Nov 2026 14:00:07 GMT"}, 7000],
    [403, {"x-ratelimit-remaining": "0", "x-ratelimit-reset": String(now / 1000 + 10)}, 10000],
    [403, {"retry-after": "5", "x-ratelimit-remaining": "0", "x-ratelimit-reset": String(now / 1000 + 10)}, 10000],
    [403, {}, 60000],
  ]) {
    let attempts = 0;
    await with_retry(async () => {
      if (++attempts === 1) throw http_error(status, "API rate limit exceeded", headers);
    });
    assert.equal(attempts, 2);
    assert.equal(delays.at(-1), expected);
  }
});

test("long server delays fail without retrying early", async (t) => {
  const {delays, warnings} = capture_retries(t);
  const error = http_error(429, "Rate limit exceeded", {"retry-after": "3600"});
  let attempts = 0;
  await assert.rejects(with_retry(async () => { attempts++; throw error; }),
    (actual) => actual === error);
  assert.equal(attempts, 1);
  assert.deepEqual(delays, []);
  assert.match(warnings[0], /retry delay exceeds 60 seconds/);
});

test("network failures retry", async (t) => {
  const {delays} = capture_retries(t);
  let attempts = 0;
  await with_retry(async () => {
    if (++attempts === 1) throw new TypeError("fetch failed", {
      cause: Object.assign(new Error("reset"), {code: "ECONNRESET"}),
    });
  });
  assert.deepEqual(delays, [1000]);
});

test("HTTP errors retain their status, body, URL, and diagnostic headers", async (t) => {
  t.mock.method(global, "fetch", async () => new Response(
    '{"message":"Forbidden"}', {status: 403, headers: {"x-github-request-id": "request-123"}}));
  await assert.rejects(get_json("https://example.com/channels"), (error) => {
    const message = describe_error(error);
    assert.match(message, /https:\/\/example.com\/channels/);
    assert.match(message, /HTTP 403/);
    assert.match(message, /Forbidden/);
    assert.match(message, /x-github-request-id=request-123/);
    return true;
  });
});

test("JSON requests retry server errors and do not send GitHub credentials", async (t) => {
  const {delays} = capture_retries(t);
  let attempts = 0;
  t.mock.method(global, "fetch", async (url, options) => {
    assert.equal(options.headers.Authorization, undefined);
    assert.ok(options.signal instanceof AbortSignal);
    return ++attempts === 1
      ? new Response("Temporarily unavailable", {status: 503})
      : Response.json({status: "success"});
  });
  assert.deepEqual(await get_json("https://example.com/channels"), {status: "success"});
  assert.deepEqual(delays, [1000]);
});

test("invalid JSON names the endpoint", async (t) => {
  t.mock.method(global, "fetch", async () => new Response("<html>Unavailable</html>"));
  await assert.rejects(get_json("https://example.com/channels"),
    /https:\/\/example.com\/channels: invalid JSON/);
});
