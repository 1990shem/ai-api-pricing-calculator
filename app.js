const state = {
  models: [],
  resultSort: {
    key: "totalUsd",
    direction: "asc",
  },
  pricingSort: {
    key: "provider",
    direction: "asc",
  },
};

const fallbackPricing = {
  last_checked: "2026-05-02",
  models: [
    {
      provider: "OpenAI",
      model: "GPT-5.5",
      input_per_million_usd: 5,
      cached_input_per_million_usd: 0.5,
      output_per_million_usd: 30,
      batch_multiplier: 0.5,
      source_url: "https://openai.com/api/pricing/",
      notes: "Frontier coding and professional work model."
    },
    {
      provider: "OpenAI",
      model: "GPT-5.4 mini",
      input_per_million_usd: 0.75,
      cached_input_per_million_usd: 0.075,
      output_per_million_usd: 4.5,
      batch_multiplier: 0.5,
      source_url: "https://openai.com/api/pricing/",
      notes: "Lower-cost model for coding, computer use, and agents."
    },
    {
      provider: "Anthropic",
      model: "Claude Sonnet 4",
      input_per_million_usd: 3,
      cached_input_per_million_usd: 0.3,
      output_per_million_usd: 15,
      batch_multiplier: 1,
      source_url: "https://docs.anthropic.com/en/docs/about-claude/pricing",
      notes: "General-purpose Claude model."
    },
    {
      provider: "Anthropic",
      model: "Claude Haiku 3.5",
      input_per_million_usd: 0.8,
      cached_input_per_million_usd: 0.08,
      output_per_million_usd: 4,
      batch_multiplier: 1,
      source_url: "https://docs.anthropic.com/en/docs/about-claude/pricing",
      notes: "Lower-cost Claude model."
    },
    {
      provider: "Google",
      model: "Gemini 2.5 Flash-Lite",
      input_per_million_usd: 0.1,
      cached_input_per_million_usd: 0.025,
      output_per_million_usd: 0.4,
      batch_multiplier: 0.5,
      source_url: "https://ai.google.dev/gemini-api/docs/pricing",
      notes: "Cost-effective Gemini model for scale."
    },
    {
      provider: "Google",
      model: "Gemini 2.5 Pro",
      input_per_million_usd: 1.25,
      cached_input_per_million_usd: 0.3125,
      output_per_million_usd: 5,
      batch_multiplier: 0.5,
      source_url: "https://ai.google.dev/gemini-api/docs/pricing",
      notes: "Higher-intelligence Gemini model. Long-context pricing may differ."
    }
  ]
};

const formatterUsd = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 2,
});

const formatterJpy = new Intl.NumberFormat("ja-JP", {
  style: "currency",
  currency: "JPY",
  maximumFractionDigits: 0,
});

const fields = {
  requests: document.querySelector("#requests"),
  inputTokens: document.querySelector("#inputTokens"),
  outputTokens: document.querySelector("#outputTokens"),
  cacheRate: document.querySelector("#cacheRate"),
  cacheRateLabel: document.querySelector("#cacheRateLabel"),
  useBatch: document.querySelector("#useBatch"),
  usdJpy: document.querySelector("#usdJpy"),
  resultRows: document.querySelector("#resultRows"),
  pricingRows: document.querySelector("#pricingRows"),
  bestChoice: document.querySelector("#bestChoice"),
  resultSortButtons: document.querySelectorAll("[data-result-sort]"),
  pricingSortButtons: document.querySelectorAll("[data-pricing-sort]"),
};

function numberValue(input) {
  const value = Number.parseFloat(input.value || "0");
  return Number.isFinite(value) && value > 0 ? value : 0;
}

function calculate(model) {
  const requests = numberValue(fields.requests);
  const inputTokens = numberValue(fields.inputTokens);
  const outputTokens = numberValue(fields.outputTokens);
  const cacheRate = numberValue(fields.cacheRate) / 100;
  const useBatch = fields.useBatch.checked;

  const monthlyInputMillions = (requests * inputTokens) / 1_000_000;
  const monthlyOutputMillions = (requests * outputTokens) / 1_000_000;
  const cachedInputMillions = monthlyInputMillions * cacheRate;
  const normalInputMillions = monthlyInputMillions - cachedInputMillions;

  const cachedRate =
    typeof model.cached_input_per_million_usd === "number"
      ? model.cached_input_per_million_usd
      : model.input_per_million_usd;

  const batchMultiplier = useBatch ? model.batch_multiplier ?? 1 : 1;
  const inputCost =
    (normalInputMillions * model.input_per_million_usd +
      cachedInputMillions * cachedRate) *
    batchMultiplier;
  const outputCost = monthlyOutputMillions * model.output_per_million_usd * batchMultiplier;

  return {
    inputCost,
    outputCost,
    totalUsd: inputCost + outputCost,
  };
}

function compareValues(a, b, direction) {
  const modifier = direction === "desc" ? -1 : 1;

  if (typeof a === "number" && typeof b === "number") {
    return (a - b) * modifier;
  }

  return (
    String(a ?? "").localeCompare(String(b ?? ""), "ja", {
      numeric: true,
      sensitivity: "base",
    }) * modifier
  );
}

function setSort(sortState, key) {
  if (sortState.key === key) {
    sortState.direction = sortState.direction === "asc" ? "desc" : "asc";
    return;
  }

  sortState.key = key;
  sortState.direction = "asc";
}

function updateSortButtons(buttons, activeState, dataName) {
  buttons.forEach((button) => {
    const key = button.dataset[dataName];
    const isActive = key === activeState.key;
    button.dataset.direction = isActive ? activeState.direction : "none";
    button.setAttribute("aria-pressed", isActive ? "true" : "false");
  });
}

function resultSortValue(row, key, usdJpy) {
  switch (key) {
    case "model":
      return `${row.model.provider} ${row.model.model}`;
    case "totalJpy":
      return row.estimate.totalUsd * usdJpy;
    case "inputCost":
      return row.estimate.inputCost;
    case "outputCost":
      return row.estimate.outputCost;
    case "totalUsd":
    default:
      return row.estimate.totalUsd;
  }
}

function pricingSortValue(model, key) {
  switch (key) {
    case "model":
      return model.model;
    case "input":
      return model.input_per_million_usd;
    case "cachedInput":
      return typeof model.cached_input_per_million_usd === "number"
        ? model.cached_input_per_million_usd
        : Number.POSITIVE_INFINITY;
    case "output":
      return model.output_per_million_usd;
    case "provider":
    default:
      return model.provider;
  }
}

function renderResults() {
  fields.cacheRateLabel.value = `${fields.cacheRate.value}%`;
  const usdJpy = numberValue(fields.usdJpy);

  const rows = state.models
    .map((model) => ({ model, estimate: calculate(model) }))
    .sort((a, b) =>
      compareValues(
        resultSortValue(a, state.resultSort.key, usdJpy),
        resultSortValue(b, state.resultSort.key, usdJpy),
        state.resultSort.direction,
      ),
    );

  fields.resultRows.innerHTML = rows
    .map(({ model, estimate }) => {
      const totalJpy = estimate.totalUsd * usdJpy;
      return `
        <tr>
          <td><strong>${model.provider}</strong><br>${model.model}</td>
          <td>${formatterUsd.format(estimate.totalUsd)}</td>
          <td>${formatterJpy.format(totalJpy)}</td>
          <td>${formatterUsd.format(estimate.inputCost)}</td>
          <td>${formatterUsd.format(estimate.outputCost)}</td>
        </tr>
      `;
    })
    .join("");

  updateSortButtons(fields.resultSortButtons, state.resultSort, "resultSort");

  if (rows.length === 0) {
    fields.bestChoice.textContent = "比較できる価格データがありません。";
    return;
  }

  const best = rows.reduce((currentBest, row) =>
    row.estimate.totalUsd < currentBest.estimate.totalUsd ? row : currentBest,
  );
  fields.bestChoice.textContent = `この条件での最安候補は ${best.model.provider} ${best.model.model}、推定 ${formatterUsd.format(
    best.estimate.totalUsd,
  )}/月 です。`;
}

function renderPricingTable() {
  fields.pricingRows.innerHTML = state.models
    .slice()
    .sort((a, b) =>
      compareValues(
        pricingSortValue(a, state.pricingSort.key),
        pricingSortValue(b, state.pricingSort.key),
        state.pricingSort.direction,
      ),
    )
    .map(
      (model) => `
        <tr>
          <td>${model.provider}</td>
          <td><strong>${model.model}</strong><br>${model.notes}</td>
          <td>${formatterUsd.format(model.input_per_million_usd)}</td>
          <td>${
            typeof model.cached_input_per_million_usd === "number"
              ? formatterUsd.format(model.cached_input_per_million_usd)
              : "-"
          }</td>
          <td>${formatterUsd.format(model.output_per_million_usd)}</td>
          <td><a href="${model.source_url}" rel="noreferrer" target="_blank">公式</a></td>
        </tr>
      `,
    )
    .join("");

  updateSortButtons(fields.pricingSortButtons, state.pricingSort, "pricingSort");
}

async function init() {
  let data = fallbackPricing;

  try {
    const response = await fetch("./data/pricing.json");
    if (response.ok) {
      data = await response.json();
    }
  } catch (error) {
    console.warn("Using embedded fallback pricing data.", error);
  }

  state.models = Array.isArray(data.models) ? data.models : [];
  renderPricingTable();
  renderResults();
}

document.querySelectorAll("input").forEach((input) => {
  input.addEventListener("input", renderResults);
  input.addEventListener("change", renderResults);
});

fields.resultSortButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setSort(state.resultSort, button.dataset.resultSort);
    renderResults();
  });
});

fields.pricingSortButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setSort(state.pricingSort, button.dataset.pricingSort);
    renderPricingTable();
  });
});

init().catch((error) => {
  fields.bestChoice.textContent = "価格データを読み込めませんでした。";
  console.error(error);
});
