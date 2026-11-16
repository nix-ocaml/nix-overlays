const timers = require("node:timers/promises");

function describe_error(error) {
  const headers = error.response?.headers ?? {};
  const details = [
    "x-github-request-id",
    "retry-after",
    "x-ratelimit-remaining",
    "x-ratelimit-reset",
  ].filter((name) => headers[name] != null)
    .map((name) => `${name}=${headers[name]}`);
  return [
    error.request?.url ?? error.response?.url,
    error.status != null ? `HTTP ${error.status}` : undefined,
    error.message,
    ...details,
  ].filter(Boolean).join(": ");
}

async function with_retry(request) {
  for (let attempt = 0; ; attempt++) {
    try {
      return await request();
    } catch (error) {
      const headers = error.response?.headers ?? {};
      const rate_limited = error.status === 429 || (error.status === 403 && (
        headers["x-ratelimit-remaining"] === "0" ||
        headers["retry-after"] != null || /rate limit/i.test(error.message)
      ));
      const network_error = [
        "ECONNRESET", "ECONNREFUSED", "ETIMEDOUT", "EAI_AGAIN", "ENOTFOUND",
      ].includes(error.code ?? error.cause?.code) ||
        ["AbortError", "TimeoutError"].includes(error.name) ||
        (error instanceof TypeError && error.message === "fetch failed");
      if (attempt === 3 || !(rate_limited || network_error ||
          error.status === 408 || error.status >= 500)) {
        throw error;
      }

      let delay = 1000 * 2 ** attempt;
      let server_delay = false;
      if (headers["retry-after"] != null) {
        const value = headers["retry-after"];
        const retry_after = /^\d+$/.test(value)
          ? Number(value) * 1000 : Date.parse(value) - Date.now();
        if (Number.isFinite(retry_after)) {
          delay = Math.max(delay, retry_after);
          server_delay = true;
        }
      }
      if (headers["x-ratelimit-remaining"] === "0" &&
          headers["x-ratelimit-reset"] != null) {
        const reset = Number(headers["x-ratelimit-reset"]) * 1000 - Date.now();
        if (Number.isFinite(reset)) {
          delay = Math.max(delay, reset);
          server_delay = true;
        }
      }
      if (rate_limited && !server_delay) {
        // Secondary limits without a reset time require at least a minute.
        delay = 60000 * 2 ** attempt;
      }
      // Fail with the reset time rather than retrying early or waiting an hour.
      if (delay > 60000) {
        console.warn(`${describe_error(error)}; retry delay exceeds 60 seconds`);
        throw error;
      }
      console.warn(`${describe_error(error)}; retry ${attempt + 1}/3 in ${delay}ms`);
      await timers.setTimeout(delay);
    }
  }
}

async function get_json(url) {
  return with_retry(async () => {
    const response = await fetch(url, {
      headers: { "User-Agent": "GithubActions", Accept: "application/json" },
      signal: AbortSignal.timeout(30000),
    });
    const body = await response.text();
    if (!response.ok) {
      throw Object.assign(new Error(body.slice(0, 2000)), {
        status: response.status,
        response: { url, headers: Object.fromEntries(response.headers) },
      });
    }
    try {
      return JSON.parse(body);
    } catch (error) {
      throw new Error(`${url}: invalid JSON: ${error.message}`);
    }
  });
}

module.exports = { describe_error, with_retry, get_json };
